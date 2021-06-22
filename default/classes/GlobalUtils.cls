global class GlobalUtils {

    public enum FleetcorCountries {
        Germany,
        Austria,
        Belgium_FR,
        Belgium_NL,
        CzechRepublic,
        France,
        Hungary,
        Lithuania,
        Luxembourg,
        Netherlands,
        Poland,
        Russia,
        Slovakia,
        Switzerland_DE,
        Switzerland_FR,
        Switzerland_IT
    }

    private static Map<String, String> fleetcorCountriesMap = new Map<String, String>{
            'Germany' => 'Germany',
            'Austria' => 'Austria',
            'Belgium_FR' => 'Belgium-FR',
            'Belgium_NL' => 'Belgium-NL',
            'CzechRepublic' => 'Czech Republic',
            'France' => 'France',
            'Hungary' => 'Hungary',
            'Lithuania' => 'Lithuania',
            'Luxembourg' => 'Luxembourg',
            'Netherlands' => 'Netherlands',
            'Poland' => 'Poland',
            'Russia' => 'Russia',
            'Slovakia' => 'Slovakia',
            'Switzerland_DE' => 'Switzerland-DE',
            'Switzerland_FR' => 'Switzerland-FR',
            'Switzerland_IT' => 'Switzerland-IT'
    };

    public static String getFleetcorCountries(String s) {
        return fleetcorCountriesMap.get(s);
    }

    /*******************************************************************************
    *  Name            : getFleetcorCountriesToCodesMap()
    *  Summary         : returns a map of country to country codes from countries picklist
    *  CreatedDate     : 02.03.2020
    *  Parameters      : -
    *  Returns         : Map <String, String> - country name => country code
    ******************************************************************************/
     public static Map <String, String> getFleetcorCountriesToCodesMap () {
        Map <String, String> countryToCodeMap = new Map <String, String> (); 
        List<Schema.PicklistEntry> countryPicklistValues = User.Countrycode.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry picklistVal : countryPicklistValues ) {
            countryToCodeMap.put(picklistVal .getLabel(), picklistVal .getValue());
        }
        return countryToCodeMap;
     }
// -------------- TERRITORY CUSTOM METADATA -----------------------    
     public static Map <String, FS_Tree_Province__mdt> provincesMap;
     public static Map <String, FS_Tree_Province__mdt> getProvincesMap () {
         if (provincesMap == null) {
             List<FS_Tree_Province__mdt> provinces = [SELECT Id, Label, Time_Zone__c, Allowed_Call_Time_From__c, Allowed_Call_Time_To__c
                                                      FROM FS_Tree_Province__mdt];
             provincesMap = new Map <String, FS_Tree_Province__mdt>();
             for (FS_Tree_Province__mdt province : provinces) {
                 provincesMap.put(province.Label, province);
             }
         }
         return provincesMap;
     }
     public static FS_Tree_Province__mdt getRegionData(sObject sObj) {
        // define timezone by value in the fields: Lead.Region__c, Account.Region__c
        String regionName;
        if (sObj.getSObjectType() == Schema.Lead.sObjectType) {
            regionName = String.valueOf(sObj.get('Region__c'));
        } else if (sObj.getSObjectType() == Schema.Opportunity.sObjectType) {
            sObject parentAcc = sObj.getSobject('Account');
            regionName = parentAcc == null ? null : String.valueOf(parentAcc.get('Region__c'));
        }
        if (regionName == null) return null;
        if (getProvincesMap().containsKey(regionName)) return getProvincesMap().get(regionName);
        return null;
    }
// -------------- WORKING WITH RECORD TYPES -----------------------    
    public static String returnRecordTypeId(String sobjectName, String recordTypeName) {
        if (Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().containsKey(recordTypeName)) {
            return Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }

        return null;
    }


    /*******************************************************************************
    *  Summary         : Return record type name
    *  CreatedDate     : 15/09/2020 by Anton Buzak
    *  Parameters      : objectName - name of sObject
                         recordTypeId - id of record type
    *  Returns         : record type name
    ******************************************************************************/
    public static String returnRecordTypeName(String objectName, Id recordTypeId) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }


    public static String getRecordTypeId(String sobjectName, String recordTypeName) {
        List<RecordType> recordTypeList = ([
                SELECT Id
                FROM RecordType
                WHERE SobjectType = :sobjectName
                AND DeveloperName = :recordTypeName
                LIMIT 1
        ]);

        if (recordTypeList == null || recordTypeList.isEmpty()) {
            throw new E2EFormRuException('GLOBAL UTILS getRecordTypeId(): ' + sobjectName + ' RecordType list is empty.');
        }

        return recordTypeList.get(0).Id;
    }


    /* Enum for getting Emarsys Accounts */
    public enum EmarsysAccounts {
        AccountEuro,
        AccountRus
    }

    private static Map<String, String> emarsysAccountsMap = new Map<String, String>{
            'AccountEuro' => 'PPR_EU',
            'AccountRus' => 'PPR'
    };

    public static String getEmarsysAccount(String s) {
        return emarsysAccountsMap.get(s);
    }

    /* Enum for getting Emarsys reaction types*/
    public enum EmarsysReactionTypesRus {
        DefaultReaction,
        Open,
        Click
    }

    private static Map<String, String> emarsysReactionTypesRusMap = new Map<String, String>{
            'DefaultReaction' => 'Reaction Open or Click',
            'Open' => 'Opened',
            'Click' => 'Clicked'
    };

    public static String getEmarsysReactionType(String s) {
        return emarsysReactionTypesRusMap.get(s);
    }

    /* DOMAIN FUNCTIONS */
    /* Blank String field if the value is null */
    public static String blankStringIfNull(String var) {
        return (var != null) ? var : '';
    }

    /* Blank Integer field if the value is null */
    public static Integer blankIntegerIfNull(Integer var) {
        return (var != null) ? var : 0;
    }

    /* Blank Integer field if the value is null */
    public static Integer blankIntegerIfNull(String var) {
        return (var != null) ? Integer.valueOf(var) : 0;
    }

    /* Blank Boolean field if the value is null */
    public static Boolean blankBooleanIfNull(Boolean var) {
        return (var != null) ? var : false;
    }

    /* Blank Decimal field if the value is null */
    public static Decimal blankDecimalIfNull(Decimal var) {
        return (var != null) ? var : 0.0;
    }

    /* changes value if new value is not blank */
    public static String changeIfHasNewValue(String oldValue, String newValue) {
        return String.isBlank(newValue) ? oldValue : newValue;
    }

    /*******************************************************************************
    *  Name            : getPicklistValuesTranslationsList()
    *  Summary         : return the list of translation of the Field picklist values
    *  CreatedDate     : 06.12.2017
    *  Parameters      : Schema.DescribeFieldResult fieldResult - filed description
    *  Returns         : List<Schema.PicklistEntry>
    ******************************************************************************/
    public static List<Schema.PicklistEntry> getPicklistValuesTranslationsList(Schema.DescribeFieldResult fieldResult) {
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        return picklist;
    }
    /*******************************************************************************
    *  Name            : getFieldsLabels()
    *  Summary         : returns List <String>  of labels for the fields list passed in the params
    *  CreatedDate     : 30.10.20
    *  Parameters      : String sObjTypeString - sObject Type of fields, List <String> fieldsAPIs - list of field pathes for whisch the labels will be found
    ******************************************************************************/
    public static List <String> getFieldsLabels (String sObjTypeString, List <String> fieldsAPIs) {
        List <String> ret = new List <String>();
        // get fields describe from the sobject 
        Map<String, Map<String, Schema.SObjectField>> sObjTypeToFieldsSchemaMap = new Map <String, Map<String, Schema.SObjectField>> ();
        sObjTypeToFieldsSchemaMap.put(sObjTypeString, getFieldsSchemaMap (sObjTypeString));
        // create headers list from fields labels
        for (String fieldPath : fieldsAPIs) {
            // get fields describe from the parent sobject if needed
            String fieldSObjType = sObjTypeString;
            String fieldAPI = fieldPath;
            if (fieldAPI.contains('.')) {
                List <String> fieldPathSplitted = fieldAPI.split('\\.');
                fieldSObjType = fieldPathSplitted[0];
                fieldAPI = fieldPathSplitted[1];
                if (!sObjTypeToFieldsSchemaMap.containsKey(fieldSObjType)) {
                    sObjTypeToFieldsSchemaMap.put(fieldSObjType, getFieldsSchemaMap (fieldSObjType));
                }
                
            }
            // get field label for the header from the fields schema
            String fieldLabel;
            try {
                fieldLabel = sObjTypeToFieldsSchemaMap.get(fieldSObjType).get(fieldAPI.toLowerCase()).getDescribe().getLabel();
            } catch (Exception ex) {
                fieldLabel = fieldAPI;
            }
            ret.add(fieldLabel);
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : getFieldsSchemaMap()
    *  Summary         : returns Map<String, Schema.SObjectField> : String - fieldAPI, Schema.SObjectField - can be used to get additonal info about the fields
    *  CreatedDate     : 30.10.20
    *  Parameters      : String sObjTypeString - sObject Type of fields
    ******************************************************************************/
    public static Map<String, Schema.SObjectField> getFieldsSchemaMap (String sObjTypeString) {
        // get fields schema
        Schema.sObjectType sObjType = Schema.getGlobalDescribe().get(sObjTypeString); 
        return sObjType.getDescribe().fields.getMap();
    }
    /*******************************************************************************
    *  Name            : getFieldValue()
    *  Summary         : returns String - field value from the sobject passed in th params
    *  CreatedDate     : 30.10.20
    *  Parameters      : sObject sObj - sobject record from which we get the field value, String fieldAPI - the field which value we get
    ******************************************************************************/
    public static String getFieldValue (sObject sObj, String fieldAPI) {
        String fieldValue;
        if (fieldAPI.contains('.')) {
            List <String> fieldPathSplitted = fieldAPI.split('\\.');
            String fieldSObjType = fieldPathSplitted[0];
            fieldAPI = fieldPathSplitted[1];
            fieldValue = String.valueOf(sObj.getSObject(fieldSObjType).get(fieldAPI));
        } else {
            fieldValue = String.valueOf(sObj.get(fieldAPI));
        }
        return fieldValue;
    }
    /*******************************************************************************
    *  Name            : getPicklistValueTranslation()
    *  Summary         : return one translation of the picklist value (if translation wasn't found - return current value)
    *  CreatedDate     : 06.12.2017
    *  Parameters      : Schema.DescribeFieldResult fieldResult - filed description
    *                    String currentValue - current value of the picklist
    *  Returns         : Schema.DescribeFieldResult
    ******************************************************************************/
    public static String getPicklistValueTranslation(Schema.DescribeFieldResult fieldResult, String currentValue) {
        String finalLabel = '';
        if (currentValue != null) {
            finalLabel = currentValue;
        }
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        if (picklist.size() > 0 && (currentValue != null)) {
            for (Schema.PicklistEntry entry : picklist) {
                if (entry.getValue().contains(currentValue)) {
                    finalLabel = entry.getLabel();
                    break;
                }
            }
        }
        return finalLabel;
    }
    /*******************************************************************************
    *  Name            : getPicklistValues(String ObjectApi_name,String Field_name)
    *  Summary         : returns list of picklis values dynamically by sObject API and FieldName
    *  CreatedDate     : 26/08/2019
    *  Parameters      : Schema.SObjectType sobject_type - sObject type of a record on which the picklist is, String Field_name - API name of the picklist field
    *  Returns         : List<Schema.PicklistEntry> - list of values of the picklist
    ******************************************************************************/
    public static List<Schema.PicklistEntry> getPicklistValues (Schema.SObjectType sobject_type,String Field_name){ 
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> picklistValues = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        return picklistValues;
    }
    /*******************************************************************************
    *  Name            : getFieldSetMembers(Schema.SObjectType sObjType, String fieldSetAPI)
    *  Summary         : get field set members by field set name
    *  CreatedDate     : 26/08/2019
    *  Parameters      : Schema.SObjectType sObjType - on which object the field set is, String fieldSetAPI - the name of the field set
    *  Returns         : List<Schema.FieldSetMember> - field members of the field set
    ******************************************************************************/
    public static List<Schema.FieldSetMember> getFieldSetMembers (Schema.SObjectType sObjType, String fieldSetAPI) {
        Schema.DescribeSObjectResult DescribeSObjectResultObj = sObjType.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetAPI);
        if (fieldSetObj == null) return null;
        return fieldSetObj.getFields();
    }
    /*******************************************************************************
    *  Name            : getFieldSetMembersAPIs(Schema.SObjectType sObjType, String fieldSetAPI)
    *  Summary         : get path (API) of fields - field set members
    *  CreatedDate     : 26/08/2019
    *  Parameters      : Schema.SObjectType sObjType - on which object the field set is, String fieldSetAPI - the name of the field set
    *  Returns         : List<String> - fields APIs - members of field sets 
    ******************************************************************************/
    public static List<String> getFieldSetMembersAPIs(Schema.SObjectType sObjType, String fieldSetAPI) {
        List<String> ret = new List<String> ();
        List<Schema.FieldSetMember> fieldSetMembers = getFieldSetMembers (sObjType, fieldSetAPI);
        if (fieldSetMembers == null || fieldSetMembers.isEmpty()) return ret;
        for (Schema.FieldSetMember fieldMember : fieldSetMembers) {
            ret.add(fieldMember.getFieldPath());
        }
        return ret;
    }

    /*******************************************************************************
    *  Name            : getTransitIdByUserId(Id userId)
    *  Summary         : get transit id of the user
    *  CreatedDate     : 07/03/2019
    *  Parameters      : Id userId
    *  Returns         : String - transit id of the user
    ******************************************************************************/
    public static String getTransitIdByUserId(Id userId) {
        return ([
                SELECT User_Transit_Id__c
                FROM User
                WHERE Id = :userId
        ]).User_Transit_Id__c;
    }

    /*******************************************************************************
     *  Name            : getAllSubRoleIds()
     *  Summary         : return set of subordinated roles by set of parent role ids
     *  CreatedDate     : 21/1/2019
     *  Parameters      : Set<Id> roleIds - parent role Ids
     *  Returns         : Set<Id>
     ******************************************************************************/
    public static Set<Id> getAllSubRoleIds(Set<Id> roleIds) {

        Set<Id> currentRoleIds = new Set<Id>();
        for (UserRole userRole : ([
                SELECT Id
                FROM UserRole
                WHERE ParentRoleId IN :roleIds
                AND ParentRoleId != NULL
        ])) {
            currentRoleIds.add(userRole.Id);
        }
        if (currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }

        return currentRoleIds;
    }

    /*******************************************************************************

    /*******************************************************************************
     *  Name            : getSubordinateRoles()
     *  Summary         : return list of subordinated roles by roleId
     *  CreatedDate     : 15/1/2018
     *  Parameters      : Id roleId - role Id
     *  Returns         : Set<Id>
     ******************************************************************************/
    public static Set<Id> getSubordinateRoles(Id roleId) {
        Map<Id, Set<Id>> parentAndChildren = new Map<Id, set<Id>>();
        Set<Id> children;
        for (UserRole ur : [select Id, ParentRoleId from UserRole]) {
            children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new set<Id>();
            children.add(ur.Id);
            parentAndChildren.put(ur.ParentRoleId, children);
        }
        return getSubordinateRoles(roleId, parentAndChildren);
    }

    /*******************************************************************************
      *  Name            : getSubordinateRoles()
      *  Summary         : use in getSubordinateRoles(Id roleId) for return list of subordinated roles by roleId
      *  CreatedDate     : 15/1/2018
      *  Parameters      : Id roleId - role Id, map<Id, set<Id>> parentAndChildren - map relo and subordinate
      *  Returns         : Set<Id>
      ******************************************************************************/
    private static Set<Id> getSubordinateRoles(Id roleId, map<Id, set<Id>> parentAndChildren) {
        Set<Id> subordinateRoles = new Set<Id>();
        Set<Id> remainingSubordinateRoles = new Set<Id>();
        if (parentAndChildren.containsKey(roleId)) {
            subordinateRoles.addAll(parentAndChildren.get(roleId));
            for (Id subRoleId : subordinateRoles) {
                remainingSubordinateRoles.addAll(getSubordinateRoles(subRoleId, parentAndChildren));
            }
        }
        subordinateRoles.addAll(remainingSubordinateRoles);
        return subordinateRoles;
    }

    /*******************************************************************************
      *  Name            : getQueueUserIdsAndRoleIds (Set <String> queueDeveloperNames)
      *  Summary         : returns map 'UserIds' => Set <Id> (all users from the queue and inner groups with 'Regular' type), 'RoleIds' => Set <Id> (all UserRole Ids from inner groups with 'Role' type)
      *  CreatedDate     : 19.06.2019
      *  Parameters      : Set <String> queueDeveloperNames - set of 'DeveloperName' field of Queues
      *  Returns         : Map <String, Set<Id>>
      ******************************************************************************/
    public static Map <String, Set<Id>> getQueueUserIdsAndRoleIds (Set <String> queueDeveloperNames){
        Map <String, Set<Id>> ret = new Map <String, Set <Id>> ();
        ret.put('UserIds', new Set <Id> () );
        ret.put('RoleIds', new Set <Id> () );

        List <GroupMember> groupMembers = [
                        SELECT Id, UserOrGroupId
                        FROM GroupMember
                        WHERE Group.DeveloperName IN :queueDeveloperNames
                        ORDER BY UserOrGroupId
                        ];
        if (!groupMembers.isEmpty()) {
            Set <Id> telesalesQueues_InnerGroupsIds = new Set <Id> ();
            for (GroupMember groupMember : groupMembers) {
                // add users from telesales groups
                if (groupMember.UserOrGroupId.getSobjectType() == User.SObjectType) {
                   ret.get('UserIds').add(groupMember.UserOrGroupId); // users in queues
                }
                // roles and inner groups
                else if (groupMember.UserOrGroupId.getSobjectType() == Group.SObjectType) {
                  telesalesQueues_InnerGroupsIds.add(groupMember.UserOrGroupId);
                }
            }

            List <Group> innerGroups = [
                            SELECT Id, Type, RelatedId,
                                    (SELECT Id, UserOrGroupId FROM GroupMembers)
                            FROM Group
                            WHERE Id IN  :telesalesQueues_InnerGroupsIds
                            ];

            if (!innerGroups.isEmpty()) {
                for (Group innerGroup : innerGroups) {
                    // roles in telesales groups
                    if (innerGroup.Type == 'Role') {
                        ret.get('RoleIds').add(innerGroup.RelatedId); // roles from inner groups
                    }
                    // inner groups in telesales groups
                    else if (innerGroup.Type == 'Regular') {
                        if (!innerGroup.GroupMembers.isEmpty()) {
                            for (GroupMember innerGroupMember : innerGroup.GroupMembers) {
                                ret.get('UserIds').add(innerGroupMember.UserOrGroupId); // users from inner groups in queues
                            }
                        }
                    }
                }
            }
        }
        return ret;
    }

    //********** Work.com  *******//
    /*******************************************************************************
    *  Name            : findFeedItemByWorkThanks()
    *  Summary         : find by WorkThanks Id related FeedItem
    *  CreatedDate     : 25/12/2017
    *  Parameters      : workThanksId - WorkThanks Id, feedItems - FeedItem list
    *  Returns         : String
    ******************************************************************************/
    public static FeedItem findFeedItemByWorkThanks(Id workThanksId, List<FeedItem> feedItems) {
        for (FeedItem item : feedItems) {
            if (item.RelatedRecordId == workThanksId) {
                return item;
            }
        }
        return null;
    }

    //***************** E2E Russia ***************//

    public enum PPRMiddleware {
        url,
        token
    }

    public static String getPPRMiddleware(String s) {
        if (s == PPRMiddleware.url.name()) {
            if (UserInfo.getOrganizationId() == '00D20000000oB2EEAU') {
                return E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Middleware_Url__c;
            } else {
                return E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Test_Middleware_Url__c;
            }
        } else if (s == PPRMiddleware.token.name()) {
            return E2E_Form_Ru_General_Settings__c.getValues('E2EFormRu').Middleware_Token__c;
        } else {
            return '';
        }
    }

    public enum E2ESource {
        PetrolPlus,
        Gaz,
        Shell
    }

    public enum E2EProduct {
        PetrolPlus_Rover,
        PetrolPlus_Gaz,
        Shell,
        Partner_Rover
    }

    //TODO:delete, deprecated
    private static Map<String, String> e2eProductMapReverse = new Map<String, String>{
            'Вездеход Online' => 'PetrolPlus_Rover',
            'ГАЗПРОМ' => 'PetrolPlus_Gaz',
            'Шелл' => 'Shell'
    };

    private static Map<String, String> e2eProductMap = new Map<String, String>{
            'PetrolPlus_Rover' => 'Вездеход Online',
            'PetrolPlus_Gaz' => 'ГАЗПРОМ',
            'Shell' => 'Шелл',
            'Partner_Rover' => 'Вездеход Online'
    };

    //TODO:delete, deprecated
    private static Map<String, String> e2eTariffMap = new Map<String, String>{
            '"Оптимальный" Карты' => '1OPTIMAL_CARDS',
            '"Оптимальный" Договор' => '1OPTIMAL_CONTRACT',
            '"Избранный" Карты' => '2CHOOSEN_CARDS',
            '"Избранный" Договор' => '2CHOOSEN_CONTRACT',
            'Карты' => '1CARDS_CARDS',
            'Договор' => '2CONTRACT_CARDS',
            //SF-559
            '"Супер" Карты' => '3SUPER_CARDS',
            '"Супер" Договор' => '3SUPER_CONTRACT',
            '"Лайт" Карты' => '4LIGHT_CARDS',
            '"Лайт" Договор' => '4LIGHT_CONTRACT',
            '"Газ" Карты' => 'GAZ_CHOOSEN_CARDS',
            '"Газ" Договор' => 'GAZ_CHOOSEN_CONTRACT'
    };

    private static Map<String, String> e2eTariffMapReverse = new Map<String, String>{
            '1OPTIMAL_CARDS' => '"Оптимальный" Карты',
            '1OPTIMAL_CONTRACT' => '"Оптимальный" Договор',
            '2CHOOSEN_CARDS' => '"Избранный" Карты',
            '2CHOOSEN_CONTRACT' => '"Избранный" Договор',
            '1CARDS_CARDS' => 'Карты',
            '2CONTRACT_CARDS' => 'Договор',
            //SF-559
            '3SUPER_CARDS' => '"Супер" Карты',
            '3SUPER_CONTRACT' => '"Супер" Договор',
            '4LIGHT_CARDS' => '"Лайт" Карты',
            '4LIGHT_CONTRACT' => '"Лайт" Договор',
            'GAZ_CHOOSEN_CARDS' => '"Газ" Карты',
            'GAZ_CHOOSEN_CONTRACT' => '"Газ" Договор'
    };

    //TODO:delete, deprecated
    public static String getE2EProductReverse(String s) {
        return e2eProductMapReverse.get(s);
    }

    public static String getE2EProduct(String s) {
        return e2eProductMap.get(s);
    }

    //TODO:delete, deprecated
    public static String getE2ETariff(String s) {
        return e2eTariffMap.get(s);
    }

    public static String getE2ETariffReverse(String s) {
        return e2eTariffMapReverse.get(s);
    }

    public enum E2ERuSteps {
        ContactDetails,
        CompanyInformation,
        Order,
        SummaryOrder,
        LegalDetails,
        PaymentDetails,
        Congratulations,
        ErrorMessage
    }

    private static Map<String, String> e2eStepMap = new Map<String, String>{
            'ContactDetails' => 'Контактные Данные',
            'CompanyInformation' => 'Данные о Компании',
            'Order' => 'Заказ',
            'SummaryOrder' => 'Информация о заказе',
            'LegalDetails' => 'Юридические реквизиты',
            'PaymentDetails' => 'Платежные реквизиты',
            'Congratulations' => 'Спасибо',
            'ErrorMessage' => 'Ошибка'
    };

    public static String getE2ESteps(String s) {
        return e2eStepMap.get(s);
    }

    public enum E2ERuErrorSteps {
        Inbound,
        RefuseToCooperate,
        IsAClient,
        SystemError
    }

    public enum E2ERuActiveModalWindows {
        PrintAgreement,
        ShowPreAgreement,
        PersonalInfoPolicy,
        SalesPromotion,
        WarningStepBankDetails
    }

    public enum E2ERuProcessStatus {
        ContactDetails,
        SFDeduplication1,
        SFDeduplication2,
        CompanyDetails,
        GetSparkData,
        CheckedInBlackList,
        ScoringPassed,
        SFDeduplication3,
        SendCrmRequest,
        CardOrderDetails,
        LegalDetails,
        PaymentDetails,
        GetReport,
        CreateContInTransit,
        SendMzkRequest,
        SaveReport
    }

    private static Map<String, List<String>> e2eRuStepsMap = new Map<String, List<String>>{
            E2ERuSteps.ContactDetails.name() => new List<String>{
                    'CONTACT DETAILS'
            },
            E2ERuSteps.CompanyInformation.name() => new List<String>{
                    'COMPANY INFORMATION'
            },
            E2ERuSteps.LegalDetails.name() => new List<String>{
                    'LEGAL DETAILS'
            },
            E2ERuSteps.PaymentDetails.name() => new List<String>{
                    'PAYMENT DETAILS'
            },
            E2ERuSteps.Order.name() => new List<String>{
                    'ORDER'
            },
            E2ERuSteps.SummaryOrder.name() => new List<String>{
                    'ORDER'
            },
            E2ERuSteps.Congratulations.name() => new List<String>{
                    'CONGRATULATIONS'
            },
            E2ERuSteps.ErrorMessage.name() => new List<String>{
                    'SYSTEM ERROR'
            }
    };

    public static List<String> getE2ERuStep(String s) {
        return e2eRuStepsMap.get(s);
    }

    public enum DeviceType {
        Desktop,
        Mobile
    }

    public static Set<String> fieldTypes = new Set<String>{
            'Text Field',
            'Picklist Field',
            'Radio-button Field',
            'Checkbox Field',
            'Slider Field',
            'Text Block',
            'URL',
            'Button'
    };

    public enum DeduplicationStatus {   // Статусы дедубликации
        E2EProcess,                     // Есть дубль по Account (ИНН)
        E2EWithOutUpdate,               // Не дубля по Account (ИНН)
        Inbound,                        // Перевод в Inbound
        Service,                        // Перевод в Сервис
        KO                              // Перевод в КО
    }

    /*******************************************************************************
    *  Name            : addBusinessDays(Date startDate, integer businessDaysToAdd)
    *  Summary         : add business days without weekends to date
    *  CreatedDate     : 06/09/2018
    *  Parameters      : Date startDate - date for start, Integer businessDaysToAdd - how many days should add
    *  Returns         : Date
    ******************************************************************************/
    public static Date addBusinessDays(Date startDate, integer businessDaysToAdd) {

        //Add or decrease in BusinessDaysToAdd days
        Date finalDate = startDate;
        Integer direction = businessDaysToAdd < 0 ? -1 : 1;
        while (businessDaysToAdd != 0) {
            finalDate = finalDate.addDays(direction);
            if (!isWeekendDay(finalDate)) {
                businessDaysToAdd -= direction;
            }
        }
        return finalDate;
    }

    public static Boolean IsWeekendDay(Date dateParam) {
        Boolean result = false;
        System.debug('dateParam = ' + dateParam);
        //Recover the day of the week
        Date startOfWeek = dateParam.toStartOfWeek();
        System.debug('startOfWeek = ' + startOfWeek);
        Integer dayOfWeek = dateParam.day() - startOfWeek.day();
        System.debug('dayOfWeek = ' + dayOfWeek);
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        System.debug('result = ' + result);
        return result;
    }

    public enum E2ERuGroupsNotification {
        Inbound,
        Service,
        CallCenter,
        MainGroup,
        None
    }

    public static Set<String> publicEmailDomain = new Set<String>{
            'gmail.com',
            'yandex.ru',
            'mail.ru',
            'inbox.ru',
            'rambler.ru',
            'hotmail.ru',
            'nm.ru',
            'hotbox.ru',
            'yahoo.com',
            'bk.ru',
            'list.ru',
            'ngs.ru'
    };

    public static List<String> reportIdsSequence = new List<String>{
            '10007',
            '10002',
            '10003',
            '10004',
            '10005',
            '10006',
            '10037',
            '10038',
            // Special condition
            '10008',
            '10009',
            '10010',
            '10034',
            '10039',
            // ДС
            '10030',
            '10031',
            '10036',
            '10028',
            '10032'
    };

    public static List<String> unitList = new List<String>{
            '',
            'одна',
            'две',
            'три',
            'четыре',
            'пять',
            'шесть',
            'семь',
            'восемь',
            'девять',
            'десять',
            'одинадцать',
            'двенадцать',
            'тринадцать',
            'четырнадцать',
            'пятнадцать',
            'шестнадцать',
            'семнадцать',
            'восемнадцать',
            'девятнадцать'
    };

    public static List<String> decimalList = new List<String>{
            '',
            '',
            'двадцать',
            'тридцать',
            'сорок',
            'пятьдесят',
            'шестьдесят',
            'семьдесят',
            'восемьдесят',
            'девяносто'
    };

    public static List<String> hundredthsList = new List<String>{
            '',
            'сто',
            'двести',
            'триста',
            'четыреста',
            'пятьсот',
            'шестьсот',
            'семьсот',
            'восемьсот',
            'девятьсот'
    };

    /*******************************************************************************
    *  Name            : convertNumberToWord(Integer inputNumber)
    *  Summary         : convert number to word, only in ranger 1 to 999
    *  CreatedDate     : 4/10/2018
    *  Parameters      : Integer inputNumber
    *  Returns         : String resultWord
    ******************************************************************************/
    public static String convertNumberToWord(Integer inputNumber) {
        if (inputNumber == null || inputNumber <= 0 || inputNumber >= 1000) {
            return '';
        }

        String resultWord = '';
        Integer remainderOfDivision = 0;
        Integer dividerBase = 100;
        while (dividerBase > 1) {
            Integer num = inputNumber / dividerBase;
            remainderOfDivision = Math.Mod(inputNumber, dividerBase);

            if (dividerBase == 100) {
                resultWord += GlobalUtils.hundredthsList.get(num) + ' ';
            } else if (dividerBase == 10) {
                resultWord += GlobalUtils.decimalList.get(num) + ' ';
            } else {
                resultWord += GlobalUtils.unitList.get(num) + ' ';
            }

            if (remainderOfDivision < 20) {
                resultWord += GlobalUtils.unitList.get(remainderOfDivision);
                return resultWord.trim();
            }

            dividerBase = dividerBase / 10;
            inputNumber = remainderOfDivision;
        }
        return resultWord.trim();
    }

    /*******************************************************************************
    *  Name            : getStringOfMonth(Integer monthNumber)
    *  Summary         : get month for russian lang by month number
    *  CreatedDate     : 4/10/2018
    *  Parameters      : Integer monthNumber
    *  Returns         : String
    ******************************************************************************/
    public static String getStringOfMonth(Integer monthNumber) {
        if (monthNumber == 1) {
            return 'января';
        } else if (monthNumber == 2) {
            return 'февраля';
        } else if (monthNumber == 3) {
            return 'марта';
        } else if (monthNumber == 4) {
            return 'апреля';
        } else if (monthNumber == 5) {
            return 'мая';
        } else if (monthNumber == 6) {
            return 'июня';
        } else if (monthNumber == 7) {
            return 'июля';
        } else if (monthNumber == 8) {
            return 'августа';
        } else if (monthNumber == 9) {
            return 'сентября';
        } else if (monthNumber == 10) {
            return 'октября';
        } else if (monthNumber == 11) {
            return 'ноября';
        } else if (monthNumber == 12) {
            return 'декабря';
        } else {
            return '';
        }
    }

    /*******************************************************************************
    *  Name            : parseNormNameForOrganization(String normName)
    *  Summary         : parse normName, which return spark
    *  CreatedDate     : 31/10/2018
    *  Parameters      : String normName
    *  Returns         : List<String> companyShortName and companyType
    ******************************************************************************/
    public static List<String> parseNormNameForOrganization(String normName) {
        String companyShortName = '';
        String companyType = '';
        String companyShortNameType = '';
        if (normName != null) {
            if (normName.contains(',')) {
                companyShortName = normName.substring(0, normName.lastIndexOf(','));
                companyType = normName.substring(normName.lastIndexOf(',') + 1).trim();
                if (companyType.contains(' ')) {
                    companyShortNameType = companyType.substringAfter(' ');
                    companyShortName = companyShortNameType + ' ' + companyShortName;
                    companyType = companyType.substringBefore(' ').trim();
                } else {
                    companyType = companyType.trim();
                }
            } else {
                companyShortName = normName;
                companyType = '';
            }
        }
        System.debug('*** companyShortName = ' + companyShortName);
        System.debug('*** companyType = ' + companyType);
        return new List<String>{companyShortName, companyType};
    }

    global enum EmailTemplateDevName {
        E2E_RU_Warning_Notification_Call_Center,
        E2E_RU_Disqualification_Lead,
        E2E_RU_Transfer_To_Service,
        E2E_RU_Transfer_To_Ko_With_INN,
        E2E_RU_Transfer_To_Ko_With_Email,
        E2E_RU_Transfer_To_Inbound,
        E2E_RU_Coordination_With_Risk_Management_Department,
        E2E_RU_Reseller,
        E2E_RU_Transfer_To_KO_More_10_Cards,
        E2E_RU_Transfer_To_KO_Manual_Entry,
        E2E_RU_Refusing_Opportunity
    }


    /*******************************************************************************
    *  Name            : generateGUID()
    *  Summary         : generates GUID that conform to UUID v4 standards
    *  CreatedDate     : 16/01/2019
    *  Parameters      :
    *  Returns         : String
    ******************************************************************************/
    public static String generateGUID() {
        String randomStringAsHex = EncodingUtil.convertToHex(Crypto.GenerateAESKey(128));

        String versionHexBits = randomStringAsHex.SubString(14, 16); // 7th bit
        String variantHexBits = randomStringAsHex.SubString(18, 20); // 9th bit

        Integer versionIntBits = convertHexToInt(versionHexBits);
        Integer variantIntBits = convertHexToInt(variantHexBits);

        Integer versionShiftedIntBits = versionIntBits & 15 | 64;  // (i & 0x0f) | 0x40
        Integer variantShiftedIntBits = variantIntBits & 63 | 128; // (i & 0x3f) | 0x80

        String versionShiftedHexBits = convertIntToHex(versionShiftedIntBits); // Always begins with 4
        String variantShiftedHexBits = convertIntToHex(variantShiftedIntBits); // Always begins with one of 8,9,a,b

        String guid = randomStringAsHex.SubString(0, 8) + '-' + randomStringAsHex.SubString(8, 12) + '-' + versionShiftedHexBits + randomStringAsHex.SubString(14, 16) + '-' + variantShiftedHexBits + randomStringAsHex.SubString(18, 20) + '-' + randomStringAsHex.substring(20);

        return guid;
    }

    private static Integer convertHexToInt(String hex) {
        Integer d0 = hexMap.IndexOf(hex.Substring(1, 2));
        Integer d1 = hexMap.IndexOf(hex.Substring(0, 1));

        Integer intval = d0 + (d1 * 16);
        return intval;
    }

    private static String convertIntToHex(Integer intval) {
        String hs0 = hexMap.Get(intval & 15); // i & 0x0f
        String hs1 = hexMap.Get(((intval >> 4) & 15)); //(i >> 4) & 0x0f
        return hs1 + hs0;
    }

    private static final List<String> hexMap = new List<String>{
            '0', '1', '2', '3', '4', '5', '6', '7',
            '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
    };

    /*******************************************************************************
    *  Name            : getValueUntypedFromJSON()
    *  Summary         : search for JsonElement in JsonObject according to looking value
    *  CreatedDate     : 16/01/2019
    *  Parameters      : Map, String
    *  Returns         : Object or null if not found
    ******************************************************************************/
    public static Object getValueUntypedFromJSON(Map<String, Object> jsonObject, String lookingValueKey) {
        if (lookingValueKey == null) {
            return null;
        }

        if (jsonObject.get(lookingValueKey) != null) {
            return jsonObject.get(lookingValueKey);
        }
        Object result;

        for (String key : jsonObject.keySet()) {
            if (jsonObject.get(key) instanceof Map<String, Object>) {
                result = getValueUntypedFromJSON((Map<String, Object>) jsonObject.get(key), lookingValueKey);
                if (result != null) {
                    return result;
                }
            } else if (jsonObject.get(key) instanceof List<Object>) {
                for (Integer i = 0; i < ((List<Object>) jsonObject.get(key)).size(); i++) {
                    if (((List<Object>) jsonObject.get(key)).get(i) instanceof Map<String, Object>) {
                        result = getValueUntypedFromJSON((Map<String, Object>) ((List<Object>) jsonObject.get(key)).get(i), lookingValueKey);
                        if (result != null) {
                            return result;
                        }
                    }
                }
            }
        }

        return null;
    }
    /*******************************************************************************
    *  Name            : escapeValuesList_singleQuotes
    *  Summary         : escape all string values in the list using escapeSingleQuotes() String method
    *  CreatedDate     : 08/11/20202
    *  Parameters      : List <String> valuesList - string values
    *  Returns         : List <string> - list with escaped values
    ******************************************************************************/
    public static List <string> escapeValuesList_singleQuotes (List <String> valuesList) {
        List <string> ret = new list <string>();
        if (valuesList == null || valuesList.isEmpty()) return ret;
        for (String valueStr : valuesList) {
            ret.add(String.escapeSingleQuotes(valueStr));
        }
        return ret;
    }
    /*******************************************************************************
    *  Name            : generateGUIDFromId
    *  Summary         : Codes SalesForce Id into GUID
    *  CreatedDate     : 17/01/2019
    *  Parameters      : Id inputId
    *  Returns         : String
    ******************************************************************************/
    public static String generateGUIDFromId(Id inputId) {
        String hex = EncodingUtil.convertToHex(EncodingUtil.base64Decode(String.valueOf(inputId) + 'ffff'));
        return hex.substring(0, 8) + '-' + hex.substring(8, 12) + '-' + hex.substring(12, 16) + '-' + hex.substring(16, 20) + '-' + hex.substring(20);
    }

    /*******************************************************************************
    *  Name            : retrieveIdFromGUID
    *  Summary         : Decodes SalesForce Id from GUID
    *  CreatedDate     : 17/01/2019
    *  Parameters      : String guid
    *  Returns         : Id
    ******************************************************************************/
    public static Id retrieveIdFromGUID(String guid) {
        return EncodingUtil.base64Encode(EncodingUtil.convertFromHex(guid.remove('-'))).substring(0, 18);
    }

    //**************** LEAD *****************//

    global enum LeadRecordTypes {
        AllStar,
        Carnet,
        CCS_Sales_process,
        Endkunde,
        Endkunde_PL_and_HU,
        Flexcard,
        Lotos,
        Retailer,
        Russian_Sales,
        ShellUniversalCard
    }

    global enum BusinessProcessType {
        PPR_API,
        Standard,                       //ручная обработка клиента через SF
        E2EClassic,                     //классический e2e процесс для клиента через форму
        E2EBusiness,                    //менеджер заполняет форму через moveToStart
        E2EZoho,                        //Выполнение функционала ЗОХО
        E2ELink,                         //клиент заполняет форму по полученной ссылке
        Undefined
    }

    //**************** CREDIT FACTORY REPORT *****************//

    global enum CreditFactoryReportRecordTypes {
        Company_Info,
        Russian_credit_check,
        Russian_credit_check_manual,
        Russian_FRAUD_check
    }

    //**************** OPPORTUNITY *****************//

    global enum OpportunityRecordTypes {
        AllStar,
        Carnet,
        CCS_Opportunity,
        Euroshell,
        Euroshell_Starts,
        Flexcard,
        Lotos,
        Russian_Sales,
        Shell_Universal_Card
    }


    global enum OpportunityStage {
        Refused,                        //Отказ возможности
        MovedToStart,                   //Возможность принята на старт
        ContractUnderSigning,           //Ожидание подписания договора
        ContractSigning,                //Договор подписан
        ContractChecking,               //Договор на проверке
        AwaitingPayment,                //Возможность в ожидании платежа
        AgreementTermsAndConditions,     //Обсуждение Условий Договора
        Check_Credit_History,
        Client_Negotiations,
        Qualified_Lead,
        Suspended_Opportunity
    }

    global static Map<GlobalUtils.OpportunityStage, String> opportunityStagesMap = new Map<GlobalUtils.OpportunityStage, String>{
            OpportunityStage.Refused => Label.Refused,
            OpportunityStage.MovedToStart => Label.MovedToStart,
            OpportunityStage.ContractUnderSigning => Label.ContractUnderSigning,
            OpportunityStage.ContractSigning => Label.ContractSigning,
            OpportunityStage.ContractChecking => Label.ContractChecking,
            OpportunityStage.AwaitingPayment => Label.AwaitingPayment,
            OpportunityStage.Check_Credit_History => Label.Check_Credit_History,
            OpportunityStage.Client_Negotiations => Label.Client_Negotiations,
            OpportunityStage.Qualified_Lead => Label.Qualified_Lead,
            OpportunityStage.Suspended_Opportunity => Label.Suspended_Opportunity,
            OpportunityStage.AgreementTermsAndConditions => Label.AgreementTermsAndConditions
    };

    global static String getOpportunityStageName(GlobalUtils.OpportunityStage opportunityStage) {
        return opportunityStagesMap.get(opportunityStage);
    }

    global enum ContractTypes {
        MultiOffer                     // договор Мультиоферта (МО)
    }

    private static Map<String, String> contractTypesMap = new Map<String, String>{
            'MultiOffer' => 'МО'
    };

    public static String getContractType(String s) {
        return contractTypesMap.get(s);
    }

    private static List<String> inboundRoles = new List<String>{
            'PPR FieldTerritory_Call Center',
            'PPR Bryansk Call Center',
            'PPR Call Center Team Leader'
    };

    public static boolean getInboundRoles(String role) {
        return inboundRoles.contains(role);
    }

    /* SERVICE CLOUD */
    global enum CaseRecordTypes {
        Development,
        Russian_Cases,
        Salesforce_Consulting,
        Support,
        Support_CCS
    }

    global enum ContactRecordTypes {
        AllStar,
        CCS_Contact_layout,
        Contact_layout,
        Russian
    }

    /*******************************************************************************
    *  Name            : containsPhraseIgnoreCase(String searchedPhrase, String sourceText, String locale)
    *  Summary         : searches for separate phrase in text using specified locale and ignoring case
    *  CreatedDate     : 05/06/2019
    *  Parameters      : String searchedPhrase - keyword to be searched for, String sourceText, @Nullable String locale
    *  Returns         : Boolean - whether searched phrase was found in source text or not
    ******************************************************************************/
    public static Boolean containsPhraseIgnoreCase(String searchedPhrase, String sourceText, String locale) {
        if (locale == null) {
            locale = Locales.en.name();
        }
        String regEx = '\\b'+ searchedPhrase.toLowerCase(locale) + '\\b';
        Pattern pattern = Pattern.compile(regEx);
        Matcher matcher = pattern.matcher(sourceText.toLowerCase(locale));
        return matcher.find();
    }

    /*******************************************************************************
    *  Name            : isPhraseFoundInText
    *  Summary         : translates language based on the queue dev name to appropriate locale
    *  CreatedDate     : 05/06/2019
    *  Parameters      : String searchedPhrase - keyword to be searched for, String sourceText, String language
    *  Returns         : Boolean - whether searched phrase was found in source text or not
    ******************************************************************************/
    public static Boolean isPhraseFoundInText(String searchedPhrase, String sourceText, String language) {
        return containsPhraseIgnoreCase(searchedPhrase, sourceText, queueDevNameLocaleMap.get(language));
    }

    private static Map<String, String> queueDevNameLocaleMap = new Map<String, String> {
            'Austria_German' => Locales.de.name(),
            'Germany_German' => Locales.de.name(),
            'Switzerland_German' => Locales.de.name(),
            'Belgium_French' => Locales.fr.name(),
            'France_French' => Locales.fr.name(),
            'Luxembourg_French' => Locales.fr.name(),
            'Switzerland_French' => Locales.fr.name(),
            'Netherlands_Dutch' => Locales.nl.name(),
            'Belgium_Dutch' => Locales.nl.name(),
            'CzechRepublic_Czech' => Locales.cz.name(),
            'Hungary_Hungarian' => Locales.hu.name(),
            'Poland_Polish' => Locales.pl.name(),
            'Slovakia_Slovak' => Locales.sk.name(),
            'Switzerland_Italian' => Locales.it.name()
    };

    global enum Locales {
        de, fr, nl, cz, hu, pl, sk, it, en
    }

    global enum SupportCaseStatus {
        status_new,
        internally_updated,
        internally_waiting,
        customer_updated,
        customer_waiting,
        resolved,
        closed
    }

    global static Map<GlobalUtils.SupportCaseStatus, String> supportCaseStatusMap  = new Map<GlobalUtils.SupportCaseStatus, String> {
            SupportCaseStatus.status_new => 'New',
            SupportCaseStatus.internally_waiting => 'Internally waiting',
            SupportCaseStatus.internally_updated => 'Internally updated',
            SupportCaseStatus.customer_waiting => 'Customer waiting',
            SupportCaseStatus.customer_updated => 'Customer updated',
            SupportCaseStatus.resolved => 'Resolved',
            SupportCaseStatus.closed => 'Closed'
    };

    global static String getSupportCaseStatus(GlobalUtils.SupportCaseStatus supportCaseStatus) {
        return supportCaseStatusMap.get(supportCaseStatus);
    }

    global enum FeedItemType {
        ContentPost,
        LinkPost,
        TextPost,
        ActivityEvent
    }


    public static Boolean isAdoptionProcessLotos(Lead lead) {
        if ((lead.Sec_Channel__c == 'JITB' || lead.Sec_Channel__c == 'Inbound') &&
            (lead.LeadSource == 'Partner' || lead.LeadSource == 'popup_window' || lead.LeadSource == 'Referral' || lead.LeadSource == 'Web' || lead.LeadSource == 'Web_short-form' || lead.LeadSource == 'Inbound email') &&
            (lead.Partner_OBN__c != 'BP005' || lead.Utm_campaign__c != 'Monevia') &&
            lead.Agree_to_receive_comm_info_by_email__c == true &&
            lead.Email != null &&
            (lead.Country == 'Poland' || lead.CountryCode == 'PL')) {
            return true;
        } else {
            return false;
        }
    }


    public static Boolean isAdoptionProcessShell(Lead lead) {
        if ((lead.Sec_Channel__c == 'JITB' || lead.Sec_Channel__c == 'Inbound') &&
            lead.LeadSource != 'Inbound Call' &&
            (lead.Partner_OBN__c != 'BP005' || lead.Utm_campaign__c != 'Monevia') &&
            lead.Agree_to_receive_comm_info_by_email__c == true &&
            lead.Email != null &&
            (lead.Country == 'Poland' || lead.CountryCode == 'PL')) {
            return true;
        } else {
            return false;
        }
    }


    public static Boolean isSwitchToE2EFromFacebook(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
                lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
                lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
                lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR' ||
                lead.Country == 'Switzerland-DE' || lead.CountryCode == 'CHDE' ||
                lead.Country == 'Switzerland-FR' || lead.CountryCode == 'CHFR' ||
                lead.Country == 'Austria' || lead.CountryCode == 'AT') &&
                lead.LeadSource == 'Facebook' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    }


    public static Boolean isSwitchToE2EInboundCall(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
                lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
                lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
                lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR' ||
                lead.Country == 'Switzerland-DE' || lead.CountryCode == 'CHDE' ||
                lead.Country == 'Switzerland-FR' || lead.CountryCode == 'CHFR' ||
                lead.Country == 'Austria' || lead.CountryCode == 'AT') &&
                lead.LeadSource == 'Inbound Call' && lead.CCS_number_of_cards__c != null && lead.Email != null) {
            return true;
        }
        return false;
    }


    public static Boolean isSwitchToE2EInboundEmail(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
                lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
                lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
                lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR' ||
                lead.Country == 'Switzerland-DE' || lead.CountryCode == 'CHDE' ||
                lead.Country == 'Switzerland-FR' || lead.CountryCode == 'CHFR' ||
                lead.Country == 'Austria' || lead.CountryCode == 'AT') &&
                lead.LeadSource == 'Inbound Email' && lead.CCS_number_of_cards__c != null &&
                lead.Email != null) {
            return true;
        }
        return false;
    }


    public static Boolean isSwitchToE2EShellEmail(Lead lead) {
        if ((lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
                lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
                lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR' ||
                lead.Country == 'Switzerland-DE' || lead.CountryCode == 'CHDE' ||
                lead.Country == 'Switzerland-FR' || lead.CountryCode == 'CHFR' ||
                lead.Country == 'Austria' || lead.CountryCode == 'AT') &&
                lead.LeadSource == 'Shell Email' && lead.Email != null) {
            return true;
        }
        return false;
    }


    public static Boolean isSwitchToE2EFromPopup(Lead lead) {
        if ((lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
                lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
                lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
                lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR' ||
                lead.Country == 'Switzerland-DE' || lead.CountryCode == 'CHDE' ||
                lead.Country == 'Switzerland-FR' || lead.CountryCode == 'CHFR' ||
                lead.Country == 'Austria' || lead.CountryCode == 'AT') &&
                lead.LeadSource == 'popup_window' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    }


    public static Boolean isSwitchToE2EFromShortForm(Lead lead) {
        if ((lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
                lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
                lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR'  ||
                lead.Country == 'Switzerland-DE' || lead.CountryCode == 'CHDE' ||
                lead.Country == 'Switzerland-FR' || lead.CountryCode == 'CHFR' ||
                lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
                lead.Country == 'Austria' || lead.CountryCode == 'AT') &&
                lead.LeadSource == 'Web_LP' && lead.Number_of_Cards_facebook__c != null) {
            return true;
        }
        return false;
    }


    public static Boolean isSwitchToE2EFromPartnerJITB(Lead lead) {
        if ((((lead.Country == 'Germany' || lead.CountryCode == 'DE') && lead.Anzahl_der_Fahrzeuge__c != null) ||
                (((lead.Country == 'Switzerland-DE' || lead.CountryCode == 'CHDE') ||
                        (lead.Country == 'Switzerland-FR' || lead.CountryCode == 'CHFR')) && lead.CCS_number_of_cards__c != null))
                &&
                lead.Sec_Channel__c == 'JITB' &&
                lead.Channel__c == 'Internet' &&
                lead.LeadSource == 'Partner' &&
                lead.Salutation != null) {
            return true;
        }
        return false;
    }


    public static Boolean isSwitchToE2EManualAdoption(Lead lead) {
        if ((lead.Country == 'Netherlands' || lead.CountryCode == 'NL' ||
                lead.Country == 'Belgium-NL' || lead.CountryCode == 'BENL' ||
                lead.Country == 'Belgium-FR' || lead.CountryCode == 'BEFR'  ||
                lead.Country == 'Switzerland-DE' || lead.CountryCode == 'CHDE' ||
                lead.Country == 'Switzerland-FR' || lead.CountryCode == 'CHFR' ||
                lead.Country == 'Austria' || lead.CountryCode == 'AT' ||
                lead.Country == 'Poland' || lead.CountryCode == 'PL' ||
                lead.Country == 'Hungary' || lead.CountryCode == 'HU' ||
                lead.Country == 'Germany' || lead.CountryCode == 'DE' ||
                lead.Country == 'France' || lead.CountryCode == 'FR') &&
                lead.E2E_Manual_Adoption_Date__c != null) {
            return true;
        }
        return false;
    }


    public static Boolean isE2EAdoptionHU(Lead lead) {
        if ((lead.Country == 'Hungary' || lead.Country == 'HU') &&
                (lead.Sec_Channel__c == 'JITB' || lead.Sec_Channel__c == 'Inbound') &&
                (lead.LeadSource != 'Shell Email' && lead.LeadSource != 'Inbound Call') &&
                lead.CCS_number_of_cards__c != null &&
                lead.Agree_to_receive_comm_info_by_email__c == true &&
                lead.Email != null) {
            return true;
        }
        return false;
    }


    public static Boolean isSwitchToE2ETabletShortForm(Lead lead){
        if((lead.Country == 'Germany' || lead.CountryCode == 'DE') &&
                lead.LeadSource == 'Tablet Short Form' && lead.CCS_number_of_cards__c != null){
            return true;
        }
        return false;
    }


    public static Map<String,String> countryCodeToCountryMap = new Map<String,String>{
            'DE' => 'Germany',
            'NL' => 'Netherlands',
            'BENL' => 'Belgium-NL',
            'BEFR' => 'Belgium-FR',
            'PL' => 'Poland',
            'HU' => 'Hungary',
            'RU' => 'Russia',
            'CHDE' => 'Switzerland-DE',
            'CHFR' => 'Switzerland-FR',
            'AT' => 'Austria',
            'FR' => 'France'
    };


    public static Map<String, String> countryToCountryCodeMap = new Map<String, String>{
            'Germany' => 'DE',
            'Netherlands' => 'NL',
            'Belgium-NL' => 'BENL',
            'Belgium-FR' => 'BEFR',
            'Poland' => 'PL',
            'Hungary' => 'HU',
            'Russia' => 'RU',
            'Switzerland-DE' => 'CHDE',
            'Switzerland-FR' => 'CHFR',
            'Switzerland-IT' => 'CHIT',
            'Austria' => 'AT',
            'Slovakia' => 'SK',
            'Czech Republic' => 'CZ',
            'Luxembourg' => 'LU',
            'France' => 'FR'
    };


    public static Set<String> europeCountrySet = new Set<String>{
            'Germany',
            'Czech Republic',
            'Slovakia',
            'Switzerland-DE',
            'Switzerland-FR',
            'Switzerland-IT',
            'Luxembourg',
            'Austria',
            'Belgium-FR',
            'Belgium-NL',
            'France',
            'Hungary',
            'Netherlands',
            'Poland'
    };


    public static Set<String> welcomeEmailSet = new Set<String>{
            'Letter_8_visualforce',
            'Letter 9 visualforce [CZ]',
            'Letter 9 visualforce [SK]',
            'Letter 8 visualforce [CH-DE]',
            'Letter 8 visualforce [CH-FR]',
            'Letter 8 visualforce [CH-IT]',
            'Letter 8 visualforce [LU]',
            'Letter_8_visualforce_AT',
            'Letter_8_visualforce_[BE-FR]',
            'Letter_8_visualforce_[BE-NL]',
            'Letter_8_visualforce_[FR]',
            'Letter 9 visualforce [HU]',
            'Letter_8_visualforce_[NL]',
            'Letter_9_visualforce_PL',
            'Carnet OBD PL welcome email_VF',
            'Welcome_email_pl_shell_carnet'
    };


    /*****************************************************************************
    *  Name            : checkINN(String INN)
    *  Summary         : validation check INN
    *  CreatedDate     : 22/01/2020
    *  Parameters      : String INN
    *  Returns         : Boolean - returns TRUE if INN is valid, that is it is not empty and its length is 10 or 12.
    *                  : Otherwise returns FALSE, that is INN is not correct.
    ******************************************************************************/
    public static Boolean checkINN(String INN) {
        return String.isNotBlank(INN) && (INN.length() == 10 || INN.length() == 12) && INN.isNumeric();
    }

    /*****************************************************************************
    *  Name            : isSoleProprietor(String INN)
    *  Summary         : defines if sole proprietor or company by length of String
    *                  : NOTE: to check INN for correctness, use GlobalUtils.checkINN(String INN) first
    *  CreatedDate     : 29/01/2020
    *  Parameters      : String INN
    *  Returns         : Boolean - true when sole proprietor, false when company, else null
    ******************************************************************************/
    public static Boolean isSoleProprietor(String INN) {
        if (String.isEmpty(INN)) return null;
        switch on (INN.length()) {
            when 10 {
                return false;
            }
            when 12 {
                return true;
            }
            when else {
                return null;
            }
        }
    }

    /*****************************************************************************
    *  Name            : processDeleteResult(Database.DeleteResult deleteResult, List<String> failedRecords)
    *  Summary         : process DeleteResult
    *                  : NOTE: parameters not null
    *  CreatedDate     : 18/02/2020
    *  Parameters      : Database.DeleteResult deleteResult, List<String> failedRecords - collection where to collect errors
    *  Returns         : -
    ******************************************************************************/
    public static void processDeleteResult(Database.DeleteResult deleteResult, List<String> failedRecords) {
        if (!deleteResult.success) {
            String message = '<div>Errors with record ' + deleteResult.id + '<br>';
            for (Database.Error error : deleteResult.errors) {
                message += error.getMessage() + '. In fields: ' + error.getFields() + '<br>';
            }
            message += '</div>';
            failedRecords.add(message);
        }
    }

    /*****************************************************************************
    *  Name            : processSaveResult(Database.SaveResult saveResult, List<String> failedRecords)
    *  Summary         : process SaveResult
    *                  : NOTE: parameters not null
    *  CreatedDate     : 18/02/2020
    *  Parameters      : Database.SaveResult saveResult, List<String> failedRecords - collection where to collect errors
    *  Returns         : -
    ******************************************************************************/
    public static void processSaveResult(Database.SaveResult saveResult, List<String> failedRecords) {
        if (!saveResult.success) {
            String message = '<div>Errors with record ' + saveResult.id + '<br>';
            for (Database.Error error : saveResult.errors) {
                message += error.getMessage() + '. In fields: ' + error.getFields() + '<br>';
            }
            message += '</div>';
            failedRecords.add(message);
        }
    }

    /*****************************************************************************
    *  Name            : createOrganiozationName(String normName)
    *  Summary         : create org name, for e.g.: org_type "org_name"
    *  CreatedDate     : 07/04/2020
    *  Parameters      : String normName – org name from spark
    *  Returns         : String – organization name
    ******************************************************************************/
    public static string createOrganiozationName(String normName) {
        List<String> params = parseNormNameForOrganization(normName);
        return params.get(1) + ' "' + params.get(0) + '"';
    }


    public static StaticResource getStaticResource(String name) {
        StaticResource testCompanies = [SELECT Id, Body FROM StaticResource WHERE Name = :name LIMIT 1];
        return testCompanies;
    }


    public static Map<String, Object> getCompaniesByCountryMap(StaticResource testCompanies) {
        return (Map<String, Object>) JSON.deserializeUntyped(testCompanies.Body.toString());
    }


    public static List<Object> getListOfCustomers(Map<String, Object> testCompanies, String countryCode) {
        List<Object> listOfCustomers = new List<Object>();
        if (testCompanies.containsKey(countryCode.substring(0, 2))) {
            if (testCompanies.get(countryCode.substring(0, 2)) instanceof List<Object>) {
                listOfCustomers = (List<Object>) testCompanies.get(countryCode.substring(0, 2));
            }
        }
        return listOfCustomers;
    }

    public static String getPromocodesString(List<String> promocodes) {
        if (promocodes != null) {
            List<String> values = new List<String>();
            for (String promocode : promocodes) {
                if (String.isNotBlank(promocode)) {
                    values.add(promocode);
                }
            }
            return String.join(values, ';');
        } else {
            return '';
        }
    }
    
    /*****************************************************************************
    *  Name            : constructPhoneNumber(String code, String value, String ext)
    *  Summary         : construct phone number from parts with checking start +
    *  CreatedDate     : 15/04/2020
    *  Parameters      : String code – phone code, String value – main phone part,
    *                  : String ext – phone extention
    *  Returns         : String – full phone number
    ******************************************************************************/
    public static string constructPhoneNumber(String code, String value, String ext) {
        if (String.isBlank(code) || String.isBlank(value)) {
            return '';
        }

        String constructedPhone = '';
        if (code == '7') {
            constructedPhone = '+';
        }
        constructedPhone += code + value;
        if (String.isNotBlank(ext) && !ext.equals('-')) {
            constructedPhone += '#' + ext;
        }

        return constructedPhone;    
    }

    public static Integer parseBoolean(Boolean value) {
        return value == null ? null : value ? 1 : 0;
    }

    /*****************************************************************************
    *  Name            : checkApprovalApproved(Id recordId, String processName)
    *  Summary         : check if approval process approved
    *  CreatedDate     : 09/09/2020
    *  Parameters      : Id recordId – record id
    *                  : String processName – name of the approval process
    *  Returns         : Boolean – true if approval approved
    ******************************************************************************/
    public static Boolean checkApprovalApproved (Id recordId, String processName) {
        Boolean approvalStatus = false;
        if (recordId == null || String.isBlank(processName)) {
            return approvalStatus;
        }

        List<ProcessInstance> processInstanceList = [
            SELECT ProcessDefinition.Name 
            FROM ProcessInstance 
            WHERE Status = 'APPROVED' AND TargetObjectId =: recordId
        ];

        if (!processInstanceList.isEmpty()) {
            for (ProcessInstance processInstance : processInstanceList) {
                if (processInstance.ProcessDefinition.Name == processName) {
                    approvalStatus = true;
                    break;
                }
            }
        } 
        
        return approvalStatus;
    }

    /*****************************************************************************
    *  Name            : getPicklistLabel(String value, SObjectField field)
    *  Summary         : returns label of picklist value in current locale
    *  CreatedDate     : 03/11/2021
    *  Parameters      : String value - picklist value, SObjectField field - picklist field
    *  Returns         : String - label in current locale
    ******************************************************************************/
    public static String getPicklistLabel(String value, SObjectField field) {
        if (value != null && field != null) {
            for (Schema.PicklistEntry entry : field.getDescribe().getPicklistValues()) {
                if (entry.isActive() && entry.getValue().equals(value)) {
                    return entry.getLabel();
                }
            }
        }
        return null;
    }

    /*****************************************************************************
    *  Name            : getPickListValuesAndLabelsFromObjectField()
    *  Summary         : returns Map value,label
    *  CreatedDate     : 24/05/2021
    *  Parameters      :  -
    *  Returns         : Map<String, String> value,label
    ******************************************************************************/
    public static Map<String, String> getPickListValuesAndLabelsFromObjectField(SObjectField field) {
        if (field != null) {
            Map<String, String> pickListData = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : picklistEntry) {
                pickListData.put(pickListVal.getValue(), pickListVal.getLabel());
            }
            return pickListData;
        }
        return null;
    }

    // ================== WORKING WITH EMAILS =================
    /*****************************************************************************
    *  Name            : sendEmail_CSV
    *  Author          : Svetlana Grecheva
    *  Summary         : Sends CSV file to emails list and creates a document record if needed
    *  CreatedDate     : 21.10.2020
    *  Parameters      : List <String> emailRecievers - List of email addresses who will recieve the email,
                         String emailSubject, String emailBody - subject of the email and its body,
                         String fileName - name of the CSV file,
                         List <String> csvRowHeaders - list of headers in the CSV file
                         List <String> csvRows - list of rows in the CSV file (every row is 1 string in the list (example of the row: 'vl1, val2, val3'))
    *  Returns         : void
    *  Example         : sendEmail_CSV (new List <String> {'test@example.com'}, 'Email subject', 'Email body', 'test.csv', new List <String> {'header1','header2','header3'}, new List <String> {'val1-1,val1-2,val1-3', 'val2-1,val2-2,val2-3'}, [SELECT Id FROM Folder limit 1][0].Id);
    ******************************************************************************/
    public static void sendEmail_CSV (List <String> emailRecievers, String emailSubject, String emailBody, String fileName, List <String> csvRowHeaders, List <String> csvRows) {
        String csvColumnHeader =  String.join(csvRowHeaders,',') + '\n';
        String csvData = csvColumnHeader + String.join(csvRows,'\n');
        // create an email to send CSV file
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        fileAttachment.setFileName(fileName);
        fileAttachment.body = Blob.valueOf(csvData);
        fileAttachment.setContentType('text/CSV');
        attachments.add(fileAttachment);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailRecievers);
        mail.setSubject(emailSubject);
        mail.setHTMLBody(emailBody);
        mail.setFileAttachments(attachments);
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}