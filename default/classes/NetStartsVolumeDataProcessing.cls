/**
 * Created by Andrei.Moiseev on 16.03.2018.
 */

public class NetStartsVolumeDataProcessing extends NetStartsVolumeDataProcessingBase implements NetStartVolumeDataProcessingInterface {
    private Set<String> selectFields;
    private Map<String, String> mappingFields;
    private Map<Decimal, String> netStartsMap;
    private Map<Decimal, String> volumeMap;
    private Map<String, Object> total;
    private Map<Id, UserRole> userRoleMap;
    private Map<Id, User> userMap;
    private String filters;
    private Integer netStartsWeeksCount;
    private Integer volumeWeeksCount;
    private Integer weeksCount;

    private final Map<String, Object> rowTemplate = new Map<String, Object>();

    public NetStartsVolumeDataProcessing(String filters,
            Map<Id, UserRole> userRoleMap,
            Map<Id, User> userMap,
            Integer netStartsWeeksCount,
            Integer volumeWeeksCount,
            Integer weeksCount) {
        this.userRoleMap = userRoleMap;
        this.userMap = userMap;
        this.filters = filters;
        this.netStartsWeeksCount = netStartsWeeksCount;
        this.volumeWeeksCount = volumeWeeksCount;
        this.weeksCount = weeksCount;

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
                        'WHERE client_week_number__c <= ' + this.weeksCount + ' ORDER BY client_week_number__c)',
                'PPR_Transit_Non_Volume_First_Date__c'
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
                'PPR_Transit_First_Bill_Payed_Amount__c' => 'First Payed Transit',
                'PPR_Transit_Non_Volume_First_Date__c' => 'Transit Non Volume First Date'
        };

        this.netStartsMap = new Map<Decimal, String>();
        for (Integer i = 1; i <= this.netStartsWeeksCount; i++) {
            this.netStartsMap.put(i, 'NetStarts ' + i);
            this.rowTemplate.put('NetStarts ' + i, 0.0);
        }
        this.rowTemplate.put('Sum NetStarts', 0.0);

        this.volumeMap = new Map<Decimal, String>();
        for (Integer i = 1; i <= this.volumeWeeksCount; i++) {
            this.volumeMap.put(i, 'Volume ' + i);
            this.rowTemplate.put('Volume ' + i, 0.0);
        }

        this.rowTemplate.put('All Cards', 0.0);
        this.rowTemplate.put('Number Cards', 0.0);
        this.rowTemplate.put('Liters Weekly', 0.0);
        this.rowTemplate.put('Expected Volume', 0.0);
        this.rowTemplate.put('Reality and Expected', 0.0);
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

        Integer countWeek = 0;
        for (Opportunity opportunity : (List<Opportunity>) Database.query(resultQuery)) {

            if (opportunity.ALL_Cards__c != null) {
                totalRow.put('All Cards', ((Decimal) totalRow.get('All Cards')) + opportunity.ALL_Cards__c);
            }

            if (opportunity.PPR_Transit_Number_of_cards__c != null) {
                totalRow.put('Number Cards', ((Decimal) totalRow.get('Number Cards')) + opportunity.PPR_Transit_Number_of_cards__c);
            }

            if (opportunity.Projected_Liters_weekly__c != null) {
                totalRow.put('Liters Weekly', ((Decimal) totalRow.get('Liters Weekly')) + opportunity.Projected_Liters_weekly__c);
            }

            if (opportunity.PPR_Transit_Expected_Volume__c != null) {
                totalRow.put('Expected Volume', ((Decimal) totalRow.get('Expected Volume')) + opportunity.PPR_Transit_Expected_Volume__c);
            }

            countWeek = opportunity.Starts__r.size();
            for (Starts__c start : opportunity.Starts__r) {
                // Total NetStarts
                totalRow.put(netStartsMap.get(start.client_week_number__c), (((Decimal) totalRow.get(netStartsMap.get(start.client_week_number__c))) + start.starts__c).setScale(2));

                // Total Volume
                totalRow.put(volumeMap.get(start.client_week_number__c), (((Decimal) totalRow.get(volumeMap.get(start.client_week_number__c))) + start.volume__c).setScale(2));

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

        for (Opportunity opportunity : (List<Opportunity>) objectList) {
            Map<String, Object> row = this.rowTemplate.clone();
            for (String field : mappingFields.keySet()) {
                Object value = shapingValue(opportunity, field, this.userRoleMap, this.userMap);
                row.put(mappingFields.get(field), value);
            }

            countWeek = opportunity.Starts__r.size();
            for (Starts__c start : opportunity.Starts__r) {
                // NetStarts
                row.put(netStartsMap.get(start.client_week_number__c), start.starts__c.setScale(2));

                // Volume
                row.put(volumeMap.get(start.client_week_number__c), start.volume__c);

                // Sum NetStarts
                row.put('Sum NetStarts', ((Decimal) row.get('Sum NetStarts') + start.starts__c).setScale(2));

                // Calculate Reality and Expected (multiply on hundred for percents formatting)
                if (start.client_week_number__c == countWeek && (Decimal) row.get('Expected Volume') != 0.0) {
                    row.put('Reality and Expected', (((Decimal) start.volume__c / (((Decimal) row.get('Expected Volume')) / 4)) * 100).setScale(2));
                }
            }
            fieldsList.add(row);
        }
        return fieldsList;
    }
}