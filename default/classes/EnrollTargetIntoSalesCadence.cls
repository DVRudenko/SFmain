public class EnrollTargetIntoSalesCadence {
    public class EnrollTargetItem {
        public Id targetId;
        public String salesCadenceNameOrId;
        
        public EnrollTargetItem  (String targetId, String salesCadenceNameOrId) {
            this.targetId = targetId;
            this.salesCadenceNameOrId = salesCadenceNameOrId;
        }
    }
    
    public class EnrollTargetsList { // Naumen case data
        public List <EnrollTargetItem> inputs;
        
        public EnrollTargetsList (Map <String, String> enrollTargetsMap) {
            if (enrollTargetsMap == null || enrollTargetsMap.isEmpty()) return;
            inputs = new List <EnrollTargetItem> ();
            for (String targetId : enrollTargetsMap.keySet()) {
                String salesCadenceName = enrollTargetsMap.get(targetId );
                EnrollTargetItem targetItem = new EnrollTargetItem (targetId, salesCadenceName);
                inputs.add(targetItem);
            }  
        }
    }

    @InvocableMethod(label='Enroll Contacts In Sales Cadences' description='Uses REST Invocable Action to assign a Contact Target to a Sales Cadence')
    public static void enrollContacts(List<Id> contactIds) {
        try {
            List <PermissionSetAssignment> hvsUserAssignments = [SELECT AssigneeId 
                                                                FROM PermissionSetAssignment 
                                                                WHERE PermissionSet.Name = 'HighVelocitySalesUser2'
                                                                AND AssigneeId = :UserInfo.getUserId()];
            Boolean isHVSUser = Test.isRunningTest() ? true : !hvsUserAssignments.isEmpty();
            if (!isHVSUser) return; // the current user is not an HVS user - don't add contact to a sales cadence
            checkConvertedLeadsAndAddContactsToSalesCadence(contactIds);
        } catch (Exception e) {
            String errMsg = 'Error in EnrollTargetIntoSalesCadence.enrollContacts :: ' + e.getMessage();
            system.debug(errMsg + ' :: ' + e.getStackTraceString());
            ExceptionLogger.sendException(errMsg, e.getStackTraceString());
        }
    }
    @future(callout = true) @TestVisible
    private static void checkConvertedLeadsAndAddContactsToSalesCadence(List <Id> hvsContactsIds) {
        // find leads from which the contacts were converted
        Map <Id, Lead> convertedLeads = new Map <Id, Lead> (
                                    [SELECT ConvertedContactId 
                                    FROM Lead 
                                    WHERE ConvertedContactId IN :hvsContactsIds]
        );
        if (convertedLeads.isEmpty()) return;
        Map <Id, String> convertedLeadsInSalesCadences = new Map <Id, String> ();
        if (Test.IsRunningTest())  {
            convertedLeadsInSalesCadences.put(convertedLeads.values()[0].Id, 'TRCC test');
        } else {
            // find action cadence on which the converted leads were at the moment of conversion
            List <ActionCadenceStepTracker> salesCadencesTrackers = [SELECT ActionCadenceName, TargetId 
                                                                    FROM ActionCadenceStepTracker 
                                                                    WHERE TargetId IN:convertedLeads.keySet()
                                                                    ORDER BY LastModifiedDate DESC];
            if (salesCadencesTrackers.isEmpty()) return; // if leads wer't in a sales cadence in the moment of conversion then don't add converted contacts to a sales cadence
        
            for (ActionCadenceStepTracker tracker : salesCadencesTrackers) {
                if (convertedLeadsInSalesCadences.containsKey(tracker.targetId)) continue; 
                convertedLeadsInSalesCadences.put(tracker.targetId, tracker.ActionCadenceName);
            }
        }
        // add contacts to a sales cadence
        Map <String, String> enrollTargetsMap = new Map <String, String> ();
        for (Id leadId : convertedLeadsInSalesCadences.keySet()) {
            Lead lead = convertedLeads.get(leadId);
            Id contactIdToEnroll = lead.ConvertedContactId;
            String leadCadenceName = convertedLeadsInSalesCadences.get(leadId); // sales cadence name in which the lead was at the moment of conversion
            String contactCadenceName = leadCadenceName.startsWith('TRCC') ? 'TRCC Contacts (Oppty) - Converted Leads' : null; // sales cadence name for converted contacts
            if (contactCadenceName != null) { 
                enrollTargetsMap.put(contactIdToEnroll, contactCadenceName);
            }
        }
        sendRequest(enrollTargetsMap);
    }

    @testVisible
    private static void sendRequest(Map <String, String> enrollTargetsMap) {
        if (enrollTargetsMap == null || enrollTargetsMap.isEmpty()) return;
        EnrollTargetsList inputsData = new EnrollTargetsList (enrollTargetsMap);
        String jsonData = JSON.serializePretty(inputsData , true);
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String actionsRestURL = sfdcURL + '/services/data/v45.0/actions';
        String assignTargetRESTUrl = actionsRestURL + '/standard/assignTargetToSalesCadence';

        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        httpReq.setEndpoint(assignTargetRESTUrl);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setBody(jsonData);
        
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpReq);
        if (httpResponse.getStatusCode() != 200) {
            try {
                throw new CalloutException('Failed HTTPRequest - assignTargetToSalesCadence :: ' + httpResponse.getBody());
            } catch (Exception e) {
                String errMsg = 'ContactScoreHandler setTheHighestOppScores:: errMsg: ' + e.getMessage();
                System.debug(errMsg);
                ExceptionLogger.sendException(errMsg, e.getStackTraceString());
            } 
        }
    }
}