/**
 * Created by marekhaken on 14.04.2021.
 */

public with sharing class AccountQuickOpportunityButtonController {
    public class ConfigInfo{
        public String RecordTypeLabel;
        public String RecordTypeId;
        public String FieldName;
        public String FieldLabel;
        public String Value;
        public String ValueLabel;
        public String ScenarioName;
        public String ScenarioDescription;
        public Boolean Selected;
    }

    public class FieldInfo{
        public String fieldName;
        public String value;
    }

    @AuraEnabled
    public static String getAvailableOptions(String recId, String userId){
        String accRecordType = [SELECT RecordType.DeveloperName FROM Account WHERE Id = :recId].RecordType.DeveloperName;

        Account acc = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet()), ',') + ' FROM Account WHERE Id = :recId LIMIT 1');

        Map<String, String> ScenarioDesc = new Map<String, String>();
        List<Config_for_Account_Quick_Opportunity__c> config = [SELECT Id, Scenario_Name__c, Scenario_Description__c, Opportunity_Record_Type_Developer_Name__c, Account_Record_Type_Developer_Name__c, Opportunity_Field_API_Name__c, Opp_Field_Value_Acc_Field_Mapping__c FROM Config_for_Account_Quick_Opportunity__c WHERE Active__c = true AND Account_Record_Type_Developer_Name__c = :accRecordType ORDER BY Scenario_Description__c ASC];
        for(Config_for_Account_Quick_Opportunity__c ci : config){
            if(ci.Scenario_Description__c != null){
                ScenarioDesc.put(ci.Scenario_Name__c, ci.Scenario_Description__c);
            }
        }

        List<String> availableRTList = GetAvailableRecordTypeNamesForSObject(Opportunity.SObjectType);
        List<ConfigInfo> availableConfigs = new List<ConfigInfo>();
        //Map<String, String> scenarioDesc = new Map<String, String>();
        Set<String> configRT = new Set<String>();
        system.debug(availableRTList);
        for(Config_for_Account_Quick_Opportunity__c cf : config){
            system.debug(cf.Opportunity_Record_Type_Developer_Name__c);
            if(availableRTList.contains(cf.Opportunity_Record_Type_Developer_Name__c)){
                ConfigInfo ci = new ConfigInfo();

                String type='Opportunity';
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get(type);
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

                String fieldLabel = fieldMap.get(cf.Opportunity_Field_API_Name__c).getDescribe().getLabel();
                ci.FieldLabel = fieldLabel;
                ci.FieldName = cf.Opportunity_Field_API_Name__c;
                ci.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(cf.Opportunity_Record_Type_Developer_Name__c).getRecordTypeId();
                ci.RecordTypeLabel = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(cf.Opportunity_Record_Type_Developer_Name__c).getName();
                ci.Selected = false;
                ci.ScenarioName = cf.Scenario_Name__c;

                ci.ScenarioDescription = ScenarioDesc.get(cf.Scenario_Name__c);
                /*
                if(cf.Scenario_Description__c != null){
                    scenarioDesc.put(cf.Scenario_Name__c, cf.Scenario_Description__c);
                    ci.ScenarioDescription = cf.Scenario_Description__c;
                }else{
                    if(scenarioDesc.containsKey(cf.Scenario_Name__c)){
                        ci.ScenarioDescription = scenarioDesc.get(cf.Scenario_Name__c);
                    }
                }*/
                
                String cfValue = cf.Opp_Field_Value_Acc_Field_Mapping__c;
                String NameRegex = '^[a-zA-Z0-9_]*$';
                Pattern MyPattern = Pattern.compile(NameRegex);
                Matcher MyMatcher = MyPattern.matcher(cfValue);
                Boolean result = MyMatcher.matches();

                String typeAcc='Account';
                Map<String, Schema.SObjectType> accSchemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accountSchema = accSchemaMap.get(typeAcc);
                Map<String, Schema.SObjectField> fieldMapAccount = accountSchema.getDescribe().fields.getMap();

                Boolean addRecord = true;
                //cfvalue může obsahovat "+" - jedná se o víc polí, může obsahovat uvozovky - statická hodnota
                if(cfValue.contains('+') && ci.FieldName.toLowerCase() != 'closedate'){
                    String[] values = cfValue.split('\\+');
                    String newVal = '';
                    for(String value : values){
                        system.debug(value);
                        Pattern MyPattern2 = Pattern.compile(NameRegex);
                        Matcher MyMatcher2 = MyPattern2.matcher(value);
                        Boolean result2 = MyMatcher2.matches();
                        system.debug(result2);
                        if(!result2){
                            newVal += value.substring(1, value.length() -1);
                        }else{
                            newVal += String.valueOf(acc.get(value));
                        }
                    }
                    ci.Value = newVal;
                    ci.ValueLabel = newVal;
                }else if(cfValue.contains('+') && ci.FieldName.toLowerCase() == 'closedate') {
                    if(cfValue.substring(1, cfValue.length()).isNumeric()){
                        Integer days = Integer.valueOf(cfValue.substring(1, cfValue.length()));
                        ci.Value = String.valueOf(Date.today()+days);
                        ci.ValueLabel = String.valueOf(Date.today()+days);
                    }
                }else if(!result){
                    ci.Value = cfValue.substring(1, cfValue.length() -1);
                    ci.ValueLabel = cfValue.substring(1, cfValue.length() -1);
                }else{
                    if(fieldMapAccount.containsKey(cfValue)){
                        ci.Value = String.valueOf(acc.get(cfValue));
                        ci.ValueLabel = String.valueOf(acc.get(cfValue));
                    }else{
                        addRecord = false;
                        //Vypsat chybovou hlášku, že se pole nenašlo v mapě?
                    }
                }
                system.debug(ci);
                if(addRecord){
                    availableConfigs.add(ci);
                    configRT.add(cf.Opportunity_Record_Type_Developer_Name__c);
                }
            }
        }

        Map<Id, User> userMap = new Map<Id, User>();
        Set<Id> userIds = new Set<Id>();
        for(ConfigInfo ci : availableConfigs){
            if(ci.Value instanceOf Id){
                if(ci.Value.startsWith('005')){
                    userIds.add(ci.Value);
                }
            }
        }
        if(userIds.size() > 0){
            List<User> users = [SELECT Id, FirstName, LastName FROM User WHERE Id IN :userIds];
            for(User u : users){
                userMap.put(u.Id, u);
            }
            for(ConfigInfo ci : availableConfigs){
                if(ci.Value instanceOf Id){
                    if(userMap.containsKey(ci.Value)){
                        ci.ValueLabel = userMap.get(ci.Value).FirstName + ' ' + userMap.get(ci.Value).LastName;
                    }
                }
            }
        }

        return JSON.serialize(availableConfigs);
    }

    public static List<String> GetAvailableRecordTypeNamesForSObject(Schema.SObjectType objType) {
        List<String> names = new List<String>();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        // If there are 2 or more RecordTypes...
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
                if (i.isAvailable()
                        // Ignore the Master Record Type, whose Id always ends with 'AAA'.
                        // We check the Id because Name can change depending on the user's language.
                        && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
                    names.add(i.getDeveloperName());
            }
        }
        // Otherwise there's just the Master record type,
        // so add it in, since it MUST always be available
        else names.add(infos[0].getDeveloperName());
        return names;
    }

    @AuraEnabled
    public static String insertOpportunity(String jsonString, String scenario){
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Opportunity.fields.getMap();
        List<Config_for_Account_Quick_Opportunity__c> cfList = [SELECT Id, Offer_Integration_Name__c FROM Config_for_Account_Quick_Opportunity__c WHERE Active__c = true AND Scenario_Name__c = :scenario AND Offer_Integration_Name__c != null LIMIT 1];
        List<FieldInfo> fif = (List<FieldInfo>)JSON.deserialize(jsonString, List<FieldInfo>.class);
        Opportunity o = new Opportunity();
        for(FieldInfo fi : fif){
            system.debug(fi.value);
            Schema.SObjectField field = M.get(fi.fieldName);
            String FldType = field.getDescribe().getType()+'';
            system.debug(FldType);

            if(FldType == 'DOUBLE'){
                if(fi.value != null && fi.value.isNumeric()){
                    o.put(fi.fieldName, decimal.valueOf(fi.value));
                }
            }else if(FldType == 'DATE'){
                o.put(fi.fieldName, Date.valueOf(fi.value));
            }else if(FldType == 'DATETIME'){
                o.put(fi.fieldName, Datetime.valueOf(fi.value));
            }else{
                o.put(fi.fieldName, fi.value);
            }
            List<Pricebook2> pb2 = [SELECT Id, Name FROM Pricebook2 WHERE isStandard = true limit 1];
            if(pb2.size() > 0){
                o.Pricebook2Id = pb2[0].Id;
            }

        }
        try{
            insert o;
            if(cfList.size() > 0){
                List<Product2> product2s = [SELECT Id FROM Product2 WHERE Integration_Name__c = :cfList[0].Offer_Integration_Name__c];
                if(product2s.size() > 0){
                    OpportunityLineItem oli = new OpportunityLineItem(TotalPrice = 0, OpportunityId = o.Id, Product2Id = product2s[0].Id, Quantity = 1);
                    insert oli;
                    return o.Id;
                }else{
                    return o.Id;
                }

            }else{
                return o.Id;
            }

        }catch (Exception e){
            return e.getMessage();
        }
    }
}