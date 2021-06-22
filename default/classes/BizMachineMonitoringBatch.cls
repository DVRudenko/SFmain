/**
 * Created by marekhaken on 26/08/2020.
 */

global class BizMachineMonitoringBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global List<Account> start(Database.BatchableContext info){
        //Získání updated UID tag
        List<BizMachine_Data_Settings__c> updatedTags = [SELECT BizMachine_Tag_UID__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Updated_Tag__c = true];
        String updatedTag;
        if(updatedTags.size() > 0){
            updatedTag = updatedTags[0].BizMachine_Tag_UID__c;
        }else{
            CCSLog.writeError('BizMachine', 'Updated Tag UID is not saved', 'There are no Updated Tag UID in Custom settings!');
            return null;
        }

        List<BizMachineTagCompanies.Data>tags = BizMachineTagCompanies.parse(BizMachineWebServices.getTagCompanies(updatedTag).getBody()).data;
        Set<String> icoSet = new Set<String>();
        for(BizMachineTagCompanies.Data tag : tags){
            icoSet.add(tag.company.bid);
        }

        return [SELECT Id, CCS_Company_ID__c FROM Account WHERE CCS_Company_ID__c IN :icoSet AND BizMachine_Monitoring__c = true LIMIT 50000];
    }

    global void execute(Database.BatchableContext info, List<Account> scope){
        //Získání updated UID tag
        List<CCS_Log__c> ccsLogs = new List<CCS_Log__c>();
        List<BizMachine_Data_Settings__c> updatedTags = [SELECT BizMachine_Tag_UID__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Updated_Tag__c = true];
        String updatedTag;
        updatedTag = updatedTag;
        if(updatedTags.size() > 0){
            updatedTag = updatedTags[0].BizMachine_Tag_UID__c;
        }else{

            ccsLogs.add(new CCS_Log__c(Source__c = 'BizMachine', Message__c = 'Monitoring Tag UID is not saved', Data__c = 'There are no monitoring UID in Custom settings!', Level__c = 'Error'));

            //CCSLog.writeError('BizMachine', 'Updated Tag UID is not saved', 'There are no Updated Tag UID in Custom settings!');
        }

        Boolean nullUpdatedTag = true;
        if(updatedTag != null){
            nullUpdatedTag = false;
        }

        //Ukládání Consumption Categories do Mapy
        Map<String, String> ConsumptionMap = new Map<String, String>();
        for(BizMachine_Data_Settings__c biz : [SELECT BizMachine_Tag_UID__c, BizMachine_Tag_Name__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Consumption_Category_Tag__c = true]){
            ConsumptionMap.put(biz.BizMachine_Tag_UID__c, biz.BizMachine_Tag_Name__c);
        }

        //List namapovaných polí
        List<BizMachine_Data_Settings__c> mappingFields = [SELECT BizMachine_API_Name__c, Salesforce_API_Name__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Mapping_Field__c = true];

        //Namapované tagy
        List<BizMachine_Data_Settings__c> mappingTags = [SELECT Salesforce_API_Name__c, BizMachine_Tag_UID__c FROM BizMachine_Data_Settings__c WHERE BizMachine_Mapping_Tag__c = true];


        List<Account> accountsToUpdate = new List<Account>();
        for(Account accToUpdate:scope){
            String jsonText = BizMachineWebServices.getCompanyDetailHttpResponse(accToUpdate.CCS_Company_ID__c).getBody();
            jsonText.replace('Currency', 'Currency_x');
            accToUpdate.Consumption_Category__c = null;
            accToUpdate.Consumption_Category_Percentile__c = null;

            BizMachineCompanyClass biz = BizMachineCompanyClass.parse(jsonText);
            Map<String, Object> bMap = BizMachineCompanyClass.getBMCompanyMap(biz);

            //List namapovaných polí
            for(BizMachine_Data_Settings__c bd : mappingFields){
                if(bMap.containsKey(bd.BizMachine_API_Name__c)){
                    accToUpdate.put(bd.Salesforce_API_Name__c, bMap.get(bd.BizMachine_API_Name__c));
                }else{
                    ccsLogs.add(new CCS_Log__c(Source__c = 'BizMachine', Message__c = 'No field in BizMachine '+accToUpdate.CCS_Company_ID__c, Data__c = 'Field not found in BizMachine Callout: '+bd.BizMachine_API_Name__c, Level__c = 'Warning'));

                    //CCSLog.writeWarning('BizMachine', 'No field in BizMachine', 'Field not found in BizMachine Callout: '+bd.BizMachine_API_Name__c);
                }
            }

            BizMachineCompanyTag tags = BizMachineCompanyTag.parse(BizMachineWebServices.getCompanyTags(accToUpdate.CCS_Company_ID__c).getBody());

            Map<String, String> mapMappingTags = new Map<String, String>();
            for(BizMachine_Data_Settings__c tag : mappingTags){
                mapMappingTags.put(tag.BizMachine_Tag_UID__c, tag.Salesforce_API_Name__c);
                accToUpdate.put(tag.Salesforce_API_Name__c, false);
            }

            for(BizMachineCompanyTag.Data tag: tags.data){
                //system.debug(tag.tag.uid);
                //system.debug(tag.description);
                if(ConsumptionMap.containsKey(tag.tag.uid)){
                    accToUpdate.Consumption_Category__c = ConsumptionMap.get(tag.tag.uid);
                    if(tag.description != null){
                        accToUpdate.Consumption_Category_Percentile__c = Decimal.valueOf(tag.description);
                    }
                }

                if(mapMappingTags.containsKey(tag.tag.uid)){
                    accToUpdate.put(mapMappingTags.get(tag.tag.uid), true);
                }
            }

            //Smazání TAGU updated
            HttpResponse removeTag = BizMachineWebServices.removeTagCompanyRelation(accToUpdate.CCS_Company_ID__c, updatedTag);
            if(removeTag.getStatusCode() != 200 && removeTag.getStatusCode() != 204){
                //Uložit do logu, že se nepodařilo odstranit tag z BizMachine

                ccsLogs.add(new CCS_Log__c(Source__c = 'BizMachine', Message__c = 'Remove Tag for Company FAILED', Data__c = 'Tag for Company '+accToUpdate.CCS_Company_ID__c+' is not removed.     '+removeTag.getBody(), Level__c = 'Error'));

                //CCSLog.writeError('BizMachine', 'Remove Tag for Company FAILED', 'Tag for Company '+accToUpdate.CCS_Company_ID__c+' is not removed.     '+removeTag.getBody());
            }

            accToUpdate.Last_Modified_By_BizMachine__c = DateTime.now();
            accountsToUpdate.add(accToUpdate);
        }
        update accountsToUpdate;
        insert ccsLogs;
    }

    global void finish(Database.BatchableContext info){

    }
}