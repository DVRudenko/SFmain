public class NetStartsVolumeFilterGenerator {

    private static final String REGEX = '(\\{1\\})|(\\{2\\})|(\\{3\\})|(\\{4\\})';
    // available filter conditions
    private static final Map<String, String> templateFilters = new Map<String, String> {
            'firstPumpDate' => 'AND AccountId {1} IN (SELECT Account__c FROM Starts__c WHERE client_week_number__c <= 10) ',
            'firstPumpDateEE' => 'AND PPR_Transit_First_Pump_Date__c {1} null ',
            'countries' => 'AND Account.BillingCountryCode = {1} ',
            'country' => 'AND Registered_Country__c IN {1} ',
            'secChannel' => 'AND Sec_Channel__c = {1} ',
            'secChannelEE' => 'AND PPR_First_Contact_Inbound_Outbound__c IN {1} ',
            'accountOwner' => 'AND Account.OwnerId = {1} ',
            'role' => 'AND Account.OwnerId IN {1} ',
            'roleEE' => 'AND Owner.UserRoleId IN {1} ',
            'startsManager' => 'AND Starts_Rep__c IN {1} ',
            'startsManagerEE' => 'AND PPR_Transit_Starts_Manager__c IN {1} ',
            'offer' => 'AND Product__c = {1} ',
            'dateFrom' => 'AND CloseDate >= {1} ',
            'dateTo' => 'AND CloseDate <= {1} ',
            'transitIdNotNull' => 'AND Transit_ID__c != null ',
            'oppOwner' => 'AND OwnerId IN {1} ',
            'stageName' => 'AND StageName IN {1} ',
            'sourceOfLead' => 'AND Source_of_Lead_o__c IN {1} ',
            'dateFromPump' => 'AND PPR_Transit_First_Pump_Date__c >= {1} ',
            'dateToPump' => 'AND PPR_Transit_First_Pump_Date__c <= {1} ',
            'InnSTR' => 'AND INN_Opp__c = {1} ',
            'TransitIdSTR' => 'AND Transit_ID__c = {1} '
    };

    private final Map<String, DropDownList> dropDownInstancePool = new Map<String, DropDownList>();
    private final Map<String, Object> dataForSelector = new Map<String, Object>();

    private OnboardingReportHtmlGenerator htmlGeneratorForSelector;
    private Map<String, String> selectorNameToDataGenerator;
    private Map<String, String> labelNameBundle;
    private List<String> labels;
    private Map<Id, UserRole> userRoleMap { get; private set; }
    private Map<Id, User> userMap { get; private set; }
    private Map<String, List<object>> defaultFilters;


    public NetStartsVolumeFilterGenerator(List<String> labels,
            Map<String, String> labelNameBundle,
            Map<String, String> selectorNameToDataGenerator,
            String htmlRootId,
            Map<String, List<object>> defaultFilters,
            Map<Id, UserRole> userRoleMap,
            Map<Id, User> userMap) {
        this.labels = labels;
        this.labelNameBundle = labelNameBundle;
        this.selectorNameToDataGenerator = selectorNameToDataGenerator;
        this.defaultFilters = defaultFilters;
        this.userRoleMap = userRoleMap;
        this.userMap = userMap;
        this.htmlGeneratorForSelector = NetStartsVolumeHtmlGeneratorFactory.create(
                NetStartVolumeReportSettings.OnboardingReportHtmlGeneratorType.SELECTOR,
                new List<Object>{ this.dataForSelector, this.labelNameBundle, this.labels, htmlRootId }
        );
    }

    /*******************************************************************************
    *  Name            : getSelectorTable()
    *  Summary         : return html table with selector parameters
    *  CreatedDate     : 15/03/2018
    *  Parameters      : -
    *  Returns         : String
    ******************************************************************************/
    public String getSelectorTable() {
        fillingDataForSelector();
        return htmlGeneratorForSelector.generateReportHtmlTemplate();
    }

    /*******************************************************************************
    *  Name            : fillingDataForSelector()
    *  Summary         : filling data for selector table
    *  CreatedDate     : 15/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void fillingDataForSelector() {
        Map<String, Object> filterParams = new Map<String, Object>();
        filterParams.put('roleIds', userRoleMap.keySet());
        filterParams.put('userIds', userMap.keySet());

        for (String key : defaultFilters.keySet()) {
            filterParams.put(key, (Object)defaultFilters.get(key));
        }

        for (String key : selectorNameToDataGenerator.keySet()) {
            String className = selectorNameToDataGenerator.get(key);
            if(className == 'String'){
                dataForSelector.put(key, '');
                continue;
            }
            DropDownList v = getDropDownListInstance(className);
            dataForSelector.put(key, v.getValue(filterParams));
        }
    }

    /*******************************************************************************
    *  Name            : getDropDownListInstance()
    *  Summary         : return class instance that get DropDownList
    *  CreatedDate     : 15/03/2018
    *  Parameters      : String className - class name
    *  Returns         : DropDownList
    ******************************************************************************/
    private DropDownList getDropDownListInstance(String className) {
        if (dropDownInstancePool.containsKey(className)) {
            return dropDownInstancePool.get(className);
        }
        Type typeClass = Type.forName(className);
        DropDownList ddl = (DropDownList) typeClass.newInstance();
        dropDownInstancePool.put(className, ddl);
        return ddl;
    }


    /*******************************************************************************
    *  Name            : resolverFilters()
    *  Summary         : convert filter parameters to soql 'where' condition
    *  CreatedDate     : 15/03/2018
    *  Parameters      : Map<String, List<Object>> - map with filter parameters, that come from client
    *  Returns         : String - result where conditions
    ******************************************************************************/
    public static String resolverFilters(Map<String, List<Object>> filterConditions, Map<String, List<object>> defaultFilters) {
        Map<String, List<Object>> allFilters = new Map<String, List<Object>>();
        allFilters.putAll(defaultFilters);
        allFilters.putAll(filterConditions);

        if (allFilters != null ) {
            String whereConditions = '';
            for (String name : allFilters.keySet()) {
                whereConditions += getConditionQuery(name, allFilters.get(name), defaultFilters);
            }
            return whereConditions;
        }
        return '';
    }

    /*******************************************************************************
    *  Name            : getConditionQuery()
    *  Summary         : convert filter parameters by name to soql 'where' condition
    *  CreatedDate     : 15/03/2018
    *  Parameters      : String name - filter parameter name, List<Object> values - parameters value
    *  Returns         : String - result 'where' condition for single parameter
    ******************************************************************************/
    private static String getConditionQuery(String name, List<Object> values, Map<String, List<object>> defaultFilters) {
        System.debug(name+':'+values);
        if(name.contains('Pump')&&values.isEmpty())
            return '';
        if (templateFilters.containsKey(name)) {
            String condition = templateFilters.get(name);
            Pattern regexPattern = Pattern.compile(REGEX);
            Matcher regexMatcher = regexPattern.matcher(condition);
            for (Integer i = 1; i < regexMatcher.groupCount(); i++) {
                if (regexMatcher.find()) {
                    if (i <= values.size()) {
                        if (values.get(i - 1) != '--None--') {
                            condition = condition.replace(regexMatcher.group(i), castObject(values.get(i - 1)) );
                        } else {
                            if (defaultFilters.containsKey(name) && i < defaultFilters.get(name).size()) {
                                condition = condition.replace(regexMatcher.group(i), castObject(defaultFilters.get(name).get(i - 1)));
                            } else {
                                return '';
                            }
                        }
                    } else {
                        return '';
                    }
                }
            }
            return condition;
        }
        return '';
    }

    /*******************************************************************************
       *  Name            : castObject()
       *  Summary         : cast Object to some standard type
       *  CreatedDate     : 15/03/2018
       *  Parameters      : Object obj - Object to cast
       *  Returns         : String
       ******************************************************************************/
    private static String castObject(Object obj) {
        if (obj instanceof Integer) {
            return (String)obj;
        } else if (obj instanceof Date) {
            DateTime dtm = DateTime.newInstance(((Date)obj).year(), ((Date)obj).month(),((Date)obj).day());
            return dtm.format('yyyy-MM-dd');
        } else if (obj instanceof Set<String>) {
            return '(\'' + String.join(new List<String>((Set<String>)obj), '\', \'') + '\')';
        } else if (obj instanceof Set<Id>) {
            return '(\'' + String.join(new List<Id>((Set<Id>) obj), '\', \'') + '\')';
        }else if (obj instanceof List<String>) {
            return '(\'' + String.join((List<String>)obj, '\', \'') + '\')';
        } else if (obj instanceof String){
            return (String)obj;
        }
        return '';
    }

    /*******************************************************************************
   *  Name            : convertSearchParameters()
   *  Summary         : convert filter parameters to standard view (Map<String, List<Object>>)
   *  CreatedDate     : 15/03/2018
   *  Parameters      : Map<String, Object> inputSearchParameters - filter parameter
   *  Returns         : Map<String, List<Object>> - filter parameters
   ******************************************************************************/
    public static Map<String, List<Object>> convertSearchParameters(Map<String, Object> inputSearchParameters) {
        Map<String, List<Object>> outputParameters = new Map<String, List<Object>>();
        for (String key : inputSearchParameters.keySet()) {
            Object inputObject;
            if (key.contains('date')) {
                    try {
                        List<String> dateList = ((String)inputSearchParameters.get(key)).split('-');
                        inputObject = Date.newInstance(Integer.valueOf(dateList.get(0)), Integer.valueOf(dateList.get(1)), Integer.valueOf(dateList.get(2)));
                    }catch (Exception e) {
                        System.debug('Error '+ e.getMessage());
                    }
            } else {
                inputObject = inputSearchParameters.get(key);
            }

            if ( ! outputParameters.containsKey(key) ) {
                outputParameters.put(key, new List<Object>{inputObject});
            } else {
                outputParameters.get(key).add(inputObject);
            }
        }
        return outputParameters;
    }

    /*******************************************************************************
   *  Name            : jsonConverter()
   *  Summary         : convert json String to Map
   *  CreatedDate     : 15/03/2018
   *  Parameters      : String jsonParams - json String
   *  Returns         : Map<String, Object>
   ******************************************************************************/
    public static Map<String, Object> jsonConverter(String jsonParams) {
        Map<String, Object> filterData = new Map<String, Object>();
        JSONParser parser = JSON.createParser(jsonParams);

        parser.nextToken();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                if (parser.nextToken() != null && parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    List<String> params = new List<String>();
                    while (parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY) {
                        params.add(parser.getText());
                    }
                    filterData.put(fieldName, params);
                } else {
                    filterData.put(fieldName, parser.getText());
                }
            }
        }
        return filterData;
    }


    //// ****** Options for selected block ******//////
    public class RolesOptions extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for 'role' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            List<String> roleOptions = new List<String>{'<option value="--None--">All</option>'};

            if ( parameters != null && parameters.containsKey('roleIds') ) {
                Set<Id> roleIds = (Set<Id>)parameters.get('roleIds');

                for (UserRole role : [SELECT Name, Id FROM UserRole WHERE Id IN :roleIds ORDER BY Name]){
                    roleOptions.add('<option value="' + role.Id + '">' + role.Name + '</option>');
                }
            }
            return roleOptions;
        }
    }

    public class OwnerOptions extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for 'owner' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            List<String> ownerOptions = new List<String>{'<option value="--None--">All</option>'};

            if ( parameters != null && parameters.containsKey('userIds') ) {
                Set<Id> userIds = (Set<Id>)parameters.get('userIds');

                for (User us : [SELECT Name, Id FROM User WHERE Id IN :userIds ORDER BY Name]){
                    ownerOptions.add('<option value="' + us.Id + '">' + us.Name + '</option>');
                }
            }
            return ownerOptions;
        }
    }

    public class StartManagerOptions extends DropDownList {

       /*******************************************************************************
       *  Name            : getValueForDropDownList()
       *  Summary         : return html Options for European 'starts Manager' variable
       *  CreatedDate     : 15/03/2018
       *  Parameters      : Map<String, Object> parameters - filter parameters
       *  Returns         : Object
       ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            List<String> startManagerOptions = new List<String>{'<option value="--None--">All</option>'};

            for (User us : [SELECT Name, Id FROM User ORDER BY Name LIMIT 2000]){
                startManagerOptions.add('<option value="\'' + us.Id + '\'">' + us.Name + '</option>');
            }
            return startManagerOptions;
        }
    }

    public class StartManagerOptionsEE extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for East Europe 'starts Manager' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            List<String> startManagerOptions = new List<String>{'<option value="--None--">All</option>'};

            for (AggregateResult result : [SELECT PPR_Transit_Starts_Manager__c FROM Opportunity WHERE Transit_ID__c != null GROUP BY PPR_Transit_Starts_Manager__c]){
                startManagerOptions.add('<option value="' + result.get('PPR_Transit_Starts_Manager__c') + '">' + result.get('PPR_Transit_Starts_Manager__c') + '</option>');
            }
            return startManagerOptions;
        }
    }

    public class CountryOptions extends DropDownList {

       /*******************************************************************************
       *  Name            : getValueForDropDownList()
       *  Summary         : return html Options for European 'country' variable
       *  CreatedDate     : 15/03/2018
       *  Parameters      : Map<String, Object> parameters - filter parameters
       *  Returns         : Object
       ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            Schema.DescribeFieldResult dfr = Account.BillingCountryCode.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = dfr.getPicklistValues();
            List<String> countryOptions = new List<String>{'<option value="--None--">All</option>'};

            for (Schema.PicklistEntry ple : picklistEntries){
                countryOptions.add('<option value="' + ple.getValue() + '">' + ple.getLabel() + '</option>');
            }
            return countryOptions;
        }
    }

    public class CountryOptionsEE extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for East Europe 'country' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            Schema.DescribeFieldResult dfr = Account.BillingCountryCode.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = dfr.getPicklistValues();
            List<String> countryOptions = new List<String>();

            for (Schema.PicklistEntry ple : picklistEntries){
                if (ple.getLabel() == 'Russia' || ple.getLabel() == 'Россия') {
                    countryOptions.add('<option value="' + ple.getLabel()  + '">' + ple.getLabel() + '</option>');
                }
            }
            return countryOptions;
        }
    }

    public class SecChannelOptions extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for European 'secChannel' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            Schema.DescribeFieldResult dfr = Opportunity.Sec_Channel__c.getDescribe();
            List<Schema.PicklistEntry> pe = dfr.getPicklistValues();
            List<String> secChannelOptions = new List<String>{'<option value="--None--">All</option>'};

            for (Schema.PicklistEntry ple : pe){
                secChannelOptions.add('<option value="\'' + ple.getValue() + '\'">' + ple.getLabel() + '</option>');
            }
            return secChannelOptions;
        }
    }

    public class SecChannelOptionsEE extends DropDownList {

       /*******************************************************************************
       *  Name            : getValueForDropDownList()
       *  Summary         : return html Options for East Europe 'secChannel' variable
       *  CreatedDate     : 15/03/2018
       *  Parameters      : Map<String, Object> parameters - filter parameters
       *  Returns         : Object
       ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            Schema.DescribeFieldResult dfr = Opportunity.PPR_First_Contact_Inbound_Outbound__c.getDescribe();
            List<Schema.PicklistEntry> pe = dfr.getPicklistValues();
            List<String> secChannelOptions = new List<String>{'<option value="--None--">All</option>'};
            for (Schema.PicklistEntry ple : pe){
                secChannelOptions.add('<option value="' + ple.getValue() + '">' + ple.getLabel() + '</option>');
            }
            return secChannelOptions;
        }
    }

    public class DateFromTo extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for 'dateFrom' and 'dateTo' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            Date dateTo = null;
            Date dateFrom = null;

            if( parameters != null && parameters.containsKey('dateFrom') ) {
                dateFrom = (Date)((List<Object>)parameters.get('dateFrom')).get(0);
            }

            if ( parameters != null && parameters.containsKey('dateTo') ) {
                dateTo = (Date)((List<Object>)parameters.get('dateTo')).get(0);
            }

            return new List<Date>{ dateFrom, dateTo };
        }
    }

    public class DateFromToPump extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for 'dateFrom' and 'dateTo' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            Date dateToPump = null;
            Date dateFromPump = null;

            if( parameters != null && parameters.containsKey('dateFromPump') ) {
                dateFromPump = (Date)((List<Object>)parameters.get('dateFromPump')).get(0);
            }

            if ( parameters != null && parameters.containsKey('dateToPump') ) {
                dateToPump = (Date)((List<Object>)parameters.get('dateToPump')).get(0);
            }

            return new List<Date>{ dateFromPump, dateToPump };
        }
    }

    public class FirstPumpDateOptions extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for East Europe 'FirstPumpDate' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            return  new List<String> {
                    '<option value="--None--">All</option>',
                    '<option value="=">No</option>',
                    '<option value="!=">Yes</option>'
            };
        }
    }

    public class SourceOfLeadOptions extends DropDownList {

        /*******************************************************************************
        *  Name            : getValueForDropDownList()
        *  Summary         : return html Options for East Europe 'SourceOfLead' variable
        *  CreatedDate     : 15/03/2018
        *  Parameters      : Map<String, Object> parameters - filter parameters
        *  Returns         : Object
        ******************************************************************************/
        protected override Object getValueForDropDownList(Map<String, Object> parameters) {
            Schema.DescribeFieldResult dfr = Opportunity.Source_of_Lead_o__c.getDescribe();
            List<Schema.PicklistEntry> pe = dfr.getPicklistValues();
            List<String> sourceOfLeadOptions = new List<String>{'<option value="--None--">All</option>'};
            for (Schema.PicklistEntry ple : pe){
                sourceOfLeadOptions.add('<option value="' + ple.getValue() + '">' + ple.getLabel() + '</option>');
            }
            return sourceOfLeadOptions;
        }
    }
}