public with sharing class CCSOrderTriggerHandler {
    /*******************************************************************************
    *  Name            : CheckOzNumberUpdateOwner()
    *  Summary         : Check OZ number with data in custom settings Oz_number_checker__c .
    *  CreatedDate     : 23/03/2020
    *  ModifiedDate    : 04/09/2020
    *  Parameters      : Map<Id, CCS_Order__c> oldMap, List<CCS_Order__c> newList
    *  Returns         : void
    ******************************************************************************/
    public static void CheckOzNumberUpdateOwner(Map<Id, CCS_Order__c> oldMap, List<CCS_Order__c> newList) {
        List<CCS_Order__c> lstCCSOrder = new List<CCS_Order__c>();
        Set<Id> ccsOrderIds = new Set<Id>();
        Set<Id> ccsOwnerId = new Set<Id>();
        Set<String> ccsOrderId = new Set<String>();

        if (oldMap != null) {
            for (CCS_Order__c CCSOrder : newList) {
                if((oldMap.get(CCSOrder.Id).OZ_Number__c != CCSOrder.OZ_Number__c) ){
                    ccsOrderIds.add(CCSOrder.Id);
                }
            }
            if(!ccsOrderIds.isEmpty()){
                List<CCS_Order__c> lstOpportunitySelected = [SELECT Id, OwnerId, OZ_Number__c, Opportunity__c, Opportunity__r.OwnerId, Opportunity__r.Owner.IsActive FROM CCS_Order__c WHERE Id IN:ccsOrderIds];

                if(!lstOpportunitySelected.isEmpty()){

                    for(CCS_Order__c CCSOrderN :lstOpportunitySelected){

                        if (CCSOrderN.OZ_Number__c != null) {

                            for (Oz_number_checker__c mc : Oz_number_checker__c.getAll().values()){
                                if (CCSOrderN.OZ_Number__c == mc.OZ_Number__c) {
                                    ccsOwnerId.add(mc.UserId__c);
                                    List<User> lstUserActive = [SELECT Id, IsActive FROM User WHERE Id IN :ccsOwnerId AND IsActive = true];
                                    if (lstUserActive.size() != 0) {
                                        CCSOrderN.OwnerId = mc.UserId__c;
                                        lstCCSOrder.add(CCSOrderN);
                                    }
                                }
                            }
                        }
                        else if (CCSOrderN.Opportunity__c != null && CCSOrderN.OZ_Number__c == null) {
                            if (ccsOrderN.Opportunity__r.Owner.IsActive != false) {
                                CCSOrderN.OwnerId = CCSOrderN.Opportunity__r.OwnerId;
                                lstCCSOrder.add(CCSOrderN);
                            }
                        }
                    }
                }
            }
            if (!lstCCSOrder.isEmpty()) {
                update lstCCSOrder;
            }
        }
        else {
            for (CCS_Order__c CCSOrder :newList) {
                if(CCSOrder.OZ_Number__c != null){
                    for (Oz_number_checker__c mc : Oz_number_checker__c.getAll().values()){
                        if (CCSOrder.OZ_Number__c == mc.OZ_Number__c) {
                            ccsOwnerId.add(mc.UserId__c);
                            List<User> lstUserActive = [SELECT Id, IsActive FROM User WHERE Id IN :ccsOwnerId AND IsActive = true];
                            if (lstUserActive.size() != 0) {
                                CCSOrder.OwnerId = mc.UserId__c;
                            }
                        }
                    }
                }
                else if (CCSOrder.Opportunity__c != null && CCSOrder.OZ_Number__c == null) {
                    ccsOrderId.add(CCSOrder.Opportunity__c);
                }
            }
            if(!ccsOrderId.isEmpty()) {
                List<Opportunity> OpportunityId = [SELECT Id, OwnerId, Owner.IsActive FROM Opportunity WHERE Id = :ccsOrderId LIMIT 1];

                if(!OpportunityId.isEmpty()){
                    for (Opportunity oppN :OpportunityId){
                        for (CCS_Order__c CCSOrder :newList) {
                            if(CCSOrder.Opportunity__c != null && oppN.Owner.IsActive != false && CCSOrder.OZ_Number__c == null){
                                CCSOrder.OwnerId = oppN.OwnerId;
                            }
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : updateLeadId()
    *  Summary         : Update Lead__c on CCS_Order before insert.
    *  CreatedDate     : 01/07/2020
    *  ModifiedDate    : ---
    *  Parameters      : Map<Id, CCS_Order__c> oldMap, List<CCS_Order__c> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void updateLeadId(List<CCS_Order__c> newList) {
        Set<String> OpportunityId = new Set<String>();

        for (CCS_Order__c CCSOrder :newlist) {
            if (CCSOrder.Lead__c == null && CCSOrder.CCS_MerlinID__c != null) {
                OpportunityId.add(CCSOrder.CCS_MerlinID__c);
            }
        }

        if(!OpportunityId.isEmpty()) {
            List<Lead> LeadId = [SELECT Id FROM Lead WHERE CCS_MerlinID__c = :OpportunityId LIMIT 1];
            if(!LeadId.isEmpty()){
                for (Lead leadN :LeadId){
                    for (CCS_Order__c CCSOrder :newList) {
                        if(CCSOrder.Lead__c == null && CCSOrder.CCS_MerlinID__c != null){
                            CCSOrder.Lead__c = leadN.Id;
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************
    *  Name            : isTest()
    *  Summary         : isTest?
    *  CreatedDate     : 13/07/2020
    *  ModifiedDate    : 13/07/2020
    *  Parameters      :
    *  Returns         : Boolean
    ******************************************************************************/

    public static Boolean isTest(){
        return [SELECT Id, IsSandbox  FROM Organization][0].IsSandbox;
    }

    /*******************************************************************************
    *  Name            : sendOrderStagesToMerlin()
    *  Summary         : Send Stage, Status, Email and Date to Merlin Order on Order_Stage__c OR Order_Status__c change.
    *  CreatedDate     : 13/07/2020
    *  ModifiedDate    : 13/07/2020
    *  Parameters      : Map<Id, CCS_Order__c> oldMap, List<CCS_Order__c> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void sendOrderStagesToMerlin(Map<Id, CCS_Order__c> oldMap, List<CCS_Order__c> newList) {
        String endpoint;
        String hash;

        List<Merlin_Salesforce_Settings__c> mssl = [SELECT Name, Production_Endpoint__c, Sandbox_Endpoint__c, Hash__c FROM Merlin_Salesforce_Settings__c LIMIT 1];
        if(mssl.size() > 0){
            if(isTest()){
                endpoint = mssl[0].Sandbox_Endpoint__c;
            }else{
                endpoint = mssl[0].Production_Endpoint__c;
            }
            hash = mssl[0].Hash__c;
        }else{
            Merlin_Salesforce_Log__c msLog = new Merlin_Salesforce_Log__c();
            msLog.Name = getRandom();
            msLog.Merlin_ID__C = '00000';
            msLog.Merlin_Response__c = 'Není nastaven Endpoint';
            msLog.Merlin_Success__c = false;
            upsert msLog;
        }

        //Set for ownerIds
        Set<Id> setOwnerIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();

        for(CCS_Order__c CCSOrder : newList) {
            //If status or Stage is changed (the old value doesn't equal to the new value)
            if ((CCSOrder.Order_Stage__c != oldMap.get(CCSOrder.Id).Order_Stage__c || CCSOrder.Order_Status__c != oldMap.get(CCSOrder.Id).Order_Status__c) && UserInfo.getFirstName() != 'APICCS') {
                //Save ownerId to Set - prevent before SOQL 101 (no SOQL calls in for loops)
                //setOwnerIds.add(CCSOrder.OwnerId);
                setOwnerIds.add(UserInfo.getUserId());
            }
        }
        //"delete" duplicates
        setOwnerIds.addAll(setOwnerIds);

        //Save Users to Map
        List<User> users = [SELECT Email FROM User WHERE Id IN :setOwnerIds];
        for(User u : users){
            userMap.put(u.Id, u);
        }

        for(CCS_Order__c CCSOrder : newList){
            //If status or Stage is changed (the old value doesn't equal to the new value)
            if((CCSOrder.Order_Stage__c != oldMap.get(CCSOrder.Id).Order_Stage__c || CCSOrder.Order_Status__c != oldMap.get(CCSOrder.Id).Order_Status__c) && UserInfo.getFirstName() != 'APICCS'){

                //Hash text to MD5
                //String hash = 'LNFCwoPtJXDmjKs0P%^Q!XsyohXJKVAScz7';

                //String formattedDateTime = CCSOrder.LastModifiedDate.format('yyyy-MM-dd\' \'HH:mm:ss');
                String formattedDateTime = CCSOrder.LastModifiedDate.format('HH:mm:ss\' \'dd.MM.yyyy');

                String stringToHash = CCSOrder.CCS_MerlinID__c+CCSOrder.Order_Stage__c+CCSOrder.Order_Status__c+userMap.get(UserInfo.getUserId()).Email+formattedDateTime+hash;
                String digest = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(stringToHash)));

                //call future method
                sendDataToMerlin(endpoint, CCSOrder.CCS_MerlinID__c, CCSOrder.Order_Stage__c, CCSOrder.Order_Status__c, userMap.get(UserInfo.getUserId()).Email, formattedDateTime, digest);

            }
        }
    }

    /*******************************************************************************
    *  Name            : sendDataToMerlin()
    *  Summary         : Send Stage, Status, Email and Date to Merlin Order on Order_Stage__c OR Order_Status__c change.
                       : HttpResponse method
    *  CreatedDate     : 13/07/2020
    *  ModifiedDate    : 13/07/2020
    *  Parameters      : String endpoint, String merlinId, String stage, String status, String email, String formattedDateTime, string digest
    *  Returns         : HttpResponse
    ******************************************************************************/
    @future(callout=true)
    public static void sendDataToMerlin(String endpoint, String merlinId, String stage, String status, String email, String formattedDateTime, string digest) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String payload = 'data={ "MerlinID": "'+merlinId+'", "Stage": "'+stage+'", "Status": "'+status+'", "Email": "'+email+'", "Date": "'+formattedDateTime+'", "Digest": "'+digest+'" }';

        request.setBody(payload);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            String logMessage = ('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            Merlin_Salesforce_Log__c msLog = new Merlin_Salesforce_Log__c();
            msLog.Name = getRandom();
            msLog.Merlin_ID__C = merlinId;
            msLog.Merlin_Response__c = logMessage;
            msLog.Merlin_Success__c = false;
            upsert msLog;
        } else {
            //system.debug(response.getBody());
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Merlin_Salesforce_Log__c msLog = new Merlin_Salesforce_Log__c();
            msLog.Name = getRandom();
            msLog.Merlin_ID__C = merlinId;
            msLog.Merlin_Response__c = results.get('error').toString();
            if(results.get('success').toString() == 'true'){
                msLog.Merlin_Success__c = true;
            }else{
                msLog.Merlin_Success__c = false;
            }
            upsert msLog;
            //system.debug(results.get('success').toString());
            //system.debug(results.get('error').toString());
            //system.debug(results);

        }
    }

    public static string getRandom() {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
        String guid = '';
        while (guid.length() < 15) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            guid += chars.substring(idx, idx + 1);
        }
        return guid;

    }

    /*******************************************************************************
    *  Name            : updateOpportunityFromCCSOrder()
    *  Summary         : Update Opportunity fields from CCS Order based on Custom Settings mapping.
    *  CreatedDate     : 21/07/2020
    *  ModifiedDate    :
    *  Parameters      : Map<Id, CCS_Order__c> oldMap, List<CCS_Order__c> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void updateOpportunityFromCCSOrder(Map<Id, CCS_Order__c> oldMap, Map<Id, CCS_Order__c> newMap, Boolean onCreate) {
        Map<String, String> mapping = new Map<String, String>();
        for (CCS_Order_Opportunity_Field_Mapping__c field :CCS_Order_Opportunity_Field_Mapping__c.getAll().values()) {
            mapping.put(field.CCS_Order_Field__c, field.Opportunity_Field__c);
        }

        Map<Id, CCS_Order__c> oppOrders = new Map<Id, CCS_Order__c>();

        for(Id orderId : newMap.keySet()){
            CCS_Order__c ordr = newMap.get(orderId);
            if(onCreate){
                oppOrders.put(ordr.Opportunity__c, ordr);
            }else{
                for(String orderField : mapping.keySet()){
                    //if(oldMap.get(ordr.Id).get(orderField) != ordr.get(orderField) && newMap.get(ordr.Id).Opportunity__c != null && UserInfo.getFirstName() != 'APICCS'){
                    if(oldMap.get(ordr.Id).get(orderField) != ordr.get(orderField) && newMap.get(ordr.Id).Opportunity__c != null){
                        //Došlo ke změně pole určeného v customSettings
                        oppOrders.put(ordr.Opportunity__c, ordr);
                    }
                    else if (oldMap.get(ordr.Id).Opportunity__c != newMap.get(ordr.Id).Opportunity__c && newMap.get(ordr.Id).Opportunity__c != null){
                        oppOrders.put(ordr.Opportunity__c, ordr);
                    }
                }
            }
        }
        //Odstranění duplicit
        oppOrders.putAll(oppOrders);

        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE Id in :oppOrders.keySet()];

        map<id,Opportunity> oppMap = new map<id,Opportunity>();


        List<Opportunity> newOppties = new List<Opportunity>();
        for(Opportunity op : opportunities){
            CCS_Order__c selectedOrder = oppOrders.get(op.Id);

            for(String orderField : mapping.keySet()){
                String oppField = mapping.get(orderField);
                op.put(oppField, selectedOrder.get(orderField));
                newOppties.add(op);
            }
        }

        oppMap.putAll(newOppties);

        update oppMap.values();

    }

    /*******************************************************************************
    *  Name            : updateOpportunityStage()
    *  Summary         : Update Opportunity Stage + other related fields from CCS Order based on Custom Settings mapping.
    *  CreatedDate     : 21/07/2020
    *  ModifiedDate    :
    *  Parameters      : Map<Id, CCS_Order__c> oldMap, Map<Id, CCS_Order__c> newList
    *  Returns         : void
    ******************************************************************************/
    public static void updateOpportunityStage(Map<Id, CCS_Order__c> oldMap, Map<Id, CCS_Order__c> newList) {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Set<Id> ccsOrderIds = new Set<Id>();

        for (CCS_Order__c ccsOrder :newList.values()) {
            if(oldMap.get(ccsOrder.Id).Order_Stage__c != ccsOrder.Order_Stage__c && ccsOrder.Opportunity__c != null && UserInfo.getFirstName() != 'APICCS'){
                ccsOrderIds.add(ccsOrder.Opportunity__c);
            }
        }
        if(!ccsOrderIds.isEmpty()){
            List<Opportunity> lstOpportunitySelected = [SELECT Id, StageName, Gruende_verloren__c, Sub_stage_detail__c, CCS_Reason_Lost_Other__c, Lost_To_Competitor__c FROM Opportunity WHERE Id IN :ccsOrderIds];
            List<CCS_Order__c> lstCCSOrderSelected = [SELECT Id, Order_Stage__c, Update_From_Opportunity__c FROM CCS_Order__c WHERE Opportunity__c IN :ccsOrderIds];

            if(!lstOpportunitySelected.isEmpty()){
                for (CCS_Order__c ccsOrderN :lstCCSOrderSelected){
                    for(Opportunity oppN :lstOpportunitySelected){
                        for (CCS_Order_Opportunity_Stage_Mapping__c Stages :CCS_Order_Opportunity_Stage_Mapping__c.getAll().values()){
                            if (ccsOrderN.Order_Stage__c == Stages.Order_Stage__c && oldMap.get(ccsOrderN.Id).Update_From_Opportunity__c == ccsOrderN.Update_From_Opportunity__c) {
                                oppN.StageName = Stages.StageName__c;
                                oppN.Gruende_verloren__c = Stages.Sub_Stage__c;
                                oppN.Sub_stage_detail__c = Stages.Sub_Stage_Detail__c;
                                oppN.CCS_Reason_Lost_Other__c = Stages.Sub_Stage_Detail_Other__c;
                                oppN.Lost_To_Competitor__c = Stages.Competition__c;
                                lstOpportunity.add(oppN);
                            }
                        }
                    }
                }
            }
        }
        if (!lstOpportunity.isEmpty()) {
            update lstOpportunity;
        }
    }

    /*******************************************************************************
    *  Name            : sendCCSWelcomeEmail()
    *  Summary         : Send CCS Welcome Email CZ/SK after CCS Order is finalized. Applies only for Limit and Limit+.
    *  CreatedDate     : 06/01/2020
    *  ModifiedDate    :
    *  Parameters      : Map<Id, CCS_Order__c> newList
    *  Returns         : void
    ******************************************************************************/
    public static void sendCCSWelcomeEmail(Map<Id, CCS_Order__c> newMap) {
        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Set<Id> ccsOrderIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

        for (CCS_Order__c ccsOrder : newMap.values()) {
            if(ccsOrder.Order_Status__c == 'Objednáno' &&
                    ccsOrder.Order_Stage__c == 'Zadáno do systému' &&
                    ccsOrder.Additional_Order__c == false &&
                    (ccsOrder.Product__c == 'CCS Limit' || ccsOrder.Product__c == 'CCS Limit SK' || ccsOrder.Product__c == 'CCS Limit+' || ccsOrder.Product__c == 'CCS Limit+ SK')) {
                ccsOrderIds.add(ccsOrder.Id);
                oppIds.add(ccsOrder.Opportunity__c);
            }
        }

        if(!ccsOrderIds.isEmpty()){
            List<OrgWideEmailAddress> owaListCZ = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'zakaznicka.podpora@ccs.cz' LIMIT 1];
            List<OrgWideEmailAddress> owaListSK = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'zakaznicke@ccs.sk' LIMIT 1];
            List<Opportunity> opportunityList = [SELECT Id, Owner.Name, Owner.Email, Welcome_Email_Sent_CCS__c FROM Opportunity WHERE Id IN:oppIds];
            List<CCS_Order__c> ccsOrderList = [SELECT Id, Product_Country__c FROM CCS_Order__c WHERE Id IN:ccsOrderIds];
            String contId = [SELECT ContactID FROM OpportunityContactRole WHERE Role = 'Account administrator' AND OpportunityID = :oppIds LIMIT 1][0].ContactId;
            String ccsOrderId = [SELECT Id FROM CCS_Order__c WHERE Id IN:ccsOrderIds LIMIT 1][0].Id;

            if (contId != null) {
                for (Opportunity oppId :opportunityList) {
                    if (oppId.Welcome_Email_Sent_CCS__c == false) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        for (CCS_Order__c ccsOrder :ccsOrderList){
                            if(ccsOrder.Product_Country__c == 'CZ'){
                                mail.setSubject('Vítáme Vás mezi zákazníky CCS');
                                String orgEmailAddressId = owaListCZ.get(0).Id;
                                mail.setOrgWideEmailAddressId(orgEmailAddressId);
                            }
                            else if (ccsOrder.Product_Country__c == 'SK') {
                                mail.setSubject('Vítame Vás medzi zákazníkmi CCS');
                                String orgEmailAddressId = owaListSK.get(0).Id;
                                mail.setOrgWideEmailAddressId(orgEmailAddressId);
                            }
                        }
                        mail.setPlainTextBody(getPlainEmail(ccsOrderId, contId));
                        mail.htmlBody = getEmailPreview(ccsOrderId, contId);
                        mail.setTargetObjectId(contId);
                        //mail.setReplyTo(oppId.Owner.Email);
                        mail.setWhatId(oppId.Id);
                        mail.setSaveAsActivity(true);
                        mail.setCharset('UTF-8');
                        allEmails.add(mail);
                        oppId.Welcome_Email_Sent_CCS__c = true;
                        lstOpportunity.add(oppId);
                    }
                }
            }
        }

        if (!allEmails.isEmpty()) {
            Messaging.sendEmail(allEmails);
            update lstOpportunity;
        }
    }

    /*******************************************************************************
    *  Name            : getPlainEmail()
    *  Summary         : Gathers plain email to be used in email sender.
    *  CreatedDate     : 06/01/2020
    *  ModifiedDate    :
    *  Parameters      : Id ccsOrderId, Id conId
    *  Returns         : null
    ******************************************************************************/
    public static String getPlainEmail(Id ccsOrderId, Id conId){

        String ProductCountry = [SELECT Product_Country__c FROM CCS_Order__c WHERE Id = :ccsOrderId][0].Product_Country__c;

        if(ProductCountry == 'CZ'){
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Welcome_Email_CZ'][0].Id;
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, conId, ccsOrderId);
            return mail.plainTextBody;
        }
        else if (ProductCountry == 'SK'){
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Welcome_Email_SK'][0].Id;
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, conId, ccsOrderId);
            return mail.plainTextBody;
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : getEmailPreview()
    *  Summary         : Gathers email preview to be used in email sender.
    *  CreatedDate     : 06/01/2020
    *  ModifiedDate    :
    *  Parameters      : Id ccsOrderId, Id conId
    *  Returns         : null
    ******************************************************************************/
    public static String getEmailPreview(Id ccsOrderId, Id conId){

        String ProductCountry = [SELECT Product_Country__c FROM CCS_Order__c WHERE Id = :ccsOrderId][0].Product_Country__c;

        if(ProductCountry == 'CZ'){
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Welcome_Email_CZ'][0].Id;
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, conId, ccsOrderId);
            return mail.htmlBody;
        }
        else if (ProductCountry == 'SK'){
            String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'CCS_Welcome_Email_SK'][0].Id;
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, conId, ccsOrderId);
            return mail.htmlBody;
        }
        return null;
    }

    /*******************************************************************************
    *  Name            : updateOpportunityType()
    *  Summary         : Update Opportunity Type based on custom logic and data from CCS Order.
    *  CreatedDate     : 31/03/2021
    *  ModifiedDate    : 07/04/2021
    *  Parameters      : Map<Id, CCS_Order__c> oldMap, Map<Id, CCS_Order__c> newMap
    *  Returns         : void
    ******************************************************************************/
    public static void updateOpportunityType(Map<Id, CCS_Order__c> oldMap, Map<Id, CCS_Order__c> newMap){
        Set<Id> oppties = new Set<Id>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        List<Opportunity> updateOppties = new List<Opportunity>();

        for (CCS_Order__c ccsOrder :newMap.values()) {
            if(ccsOrder.Opportunity__c != null){
                oppties.add(ccsOrder.Opportunity__c);
            }
        }

        List<Opportunity> opportunities = [SELECT Id, Type, Owner.FirstName FROM Opportunity WHERE Id IN :oppties];
        for(Opportunity opp : opportunities){
            opportunityMap.put(opp.Id, opp);

        }

        for (CCS_Order__c o :newMap.values()) {
            if(o.Opportunity__c != null) {
                //Use this condition only in case of PB flow cycle
                if(opportunityMap.containsKey(o.Opportunity__c)){
                    Opportunity opp = opportunityMap.get(o.Opportunity__c);

                    Opportunity oppToUpdate = new Opportunity();
                    oppToUpdate.Id = o.Opportunity__c;
                    if(o.Additional_Order__c == true && opp.Owner.FirstName == 'APICCS'){
                        oppToUpdate.Type = 'BAU';
                    }else if(o.Additional_Order__c == true && opp.Owner.FirstName != 'APICCS'){
                        oppToUpdate.Type = 'Existing GFN';
                    }else{
                        oppToUpdate.Type = 'New GFN';
                    }

                    if(oldMap != null){
                        if (oldMap.get(o.Id).Update_From_Opportunity__c == o.Update_From_Opportunity__c) {
                            updateOppties.add(oppToUpdate);
                        }
                    }
                    else {
                        updateOppties.add(oppToUpdate);
                    }
                }
            }
        }

        if(updateOppties.size() > 0){
            update updateOppties;
        }
    }
}