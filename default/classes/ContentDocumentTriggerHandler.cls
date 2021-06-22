public class ContentDocumentTriggerHandler {
    /*******************************************************************************
        *  Name            : carnetDeleteCD()
        *  Summary         : before delete ContentDocumentLink check Opportunity Stagename
        *  CreatedDate     : 22/10/2020
        *  Parameters      :
        *  Returns         :
        *  Author          : INTERCODEC
        ******************************************************************************/
    public static void carnetDeleteCD(List<ContentDocument> cdList) {
        Id userProfileId = userinfo.getProfileId();
        Map<Id, ContentDocumentLink> cdlMap = new Map<Id, ContentDocumentLink>();
        Map<Id, Id> cdIdMap = new Map<Id, Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> CdIds = new Set<Id>();
        for(ContentDocument cd : cdList){
            CdIds.add(cd.Id);
        }

        Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'Carnet' AND sObjectType = 'Opportunity'].Id;
        List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :CdIds];
        for(ContentDocumentLink cdl : cdlList){
            //Check if CDL is linked with Opportunity
            if(cdl.LinkedEntityId.getSobjectType() == Opportunity.SObjectType){
                cdlMap.put(cdl.LinkedEntityId, cdl);
            }
        }

        //Get Carnet oppties
        List<Opportunity> oppties = [SELECT Id FROM Opportunity WHERE Id IN :cdlMap.keySet() AND RecordTypeId = :recordTypeId AND StageName = 'Closed Won'];

        if(oppties.size() >= 0){
            Set<Id> allowedProfiles = new Set<Id>();
            List<Carnet_Closed_Won_Files_Allowed_Profiles__c> allProfs = [SELECT Name, Profile_Id__c FROM Carnet_Closed_Won_Files_Allowed_Profiles__c];
            for(Carnet_Closed_Won_Files_Allowed_Profiles__c ap : allProfs){
                allowedProfiles.add(ap.Profile_Id__c);
            }
            for(Opportunity opp : oppties){
                oppIds.add(opp.Id);
            }

            for(ContentDocumentLink cdl : cdlList){
                if(oppIds.contains(cdl.LinkedEntityId) && !allowedProfiles.contains(userProfileId)){
                    //cdl.addError(Label.Carnet_Closed_Won_Files_Block_Delete);
                    cdIdMap.put(cdl.ContentDocumentId, cdl.ContentDocumentId);
                }
            }

            for(ContentDocument cd : cdList){
                if(cdIdMap.containsKey(cd.Id) && !allowedProfiles.contains(userProfileId)){
                    cd.addError(Label.Carnet_Closed_Won_Files_Block_Delete);
                }
            }
        }
    }
}