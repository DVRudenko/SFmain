public class PD_NewLeadController extends PhoneNumbersControllerHelper {

    public Map<String, String> fields {get;set;}

    public String externalId {get;set;}
    public String PD_Token {get; set;}
    public String PD_URL {get; set;}
    public Boolean PD_IsActive {get; set;}

    public Id leadId {get;set;}
    public Boolean recordCreated{get{return recordCreated == null ? false : recordCreated;} set;}
    public Boolean recordUpdated{get{return recordUpdated == null ? false : recordUpdated;} set;}
    public Boolean pdDataSaved {get;set;} // for Lighning redirect to edit page
    public Boolean finishedEditing {get;set;}

    private void init() {
        this.pdDataSaved = ApexPages.currentPage().getParameters().get('pdDataSaved') == 'true';
        PD_Setting__c mc = PD_Setting__c.getOrgDefaults();
        PD_Token = mc.Token__c;
        PD_URL = mc.URL__c;
        PD_IsActive = mc.IsActive__c;
        if (PD_Token == null) throw new PD_Exception('Token is empty'); //PD logic switch here
    }

    public PD_NewLeadController(ApexPages.StandardSetController stdController) {
        init();
    }

    public PD_NewLeadController(ApexPages.StandardController stdController) {
        init();

        leadId = stdController.getId();
        if (this.pdDataSaved) {
            Lead newLead = [SELECT Id, Source_of_Lead__c FROM Lead WHERE Id = :leadId];
            this.finishedEditing = newLead.Source_of_Lead__c != null;
            if (!finishedEditing) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.notif_pd_PDDataWasSaved));
            }
        }
        Boolean isNewRecord = leadId == null;
        initPhones (isNewRecord, Schema.Lead.sObjectType, stdController);

        String[] fieldsToSelect = new String[]{};
        List<Schema.FieldSetMember>  pdFields = GlobalUtils.getFieldSetMembers (Schema.Lead.sObjectType, 'PD_Fields');
        for (Schema.FieldSetMember pdField : pdFields) {
            fieldsToSelect.add(pdField.getFieldPath());
        }

        Lead ct = null;
        if (leadId != null) {
            fieldsToSelect.add('Id');
            String query = 'SELECT ' + String.join(fieldsToSelect, ',') + ', PD_ExternalId__c FROM Lead WHERE Id = \'' + leadId + '\'';
            ct = Database.query(query);
            externalId = ct.PD_ExternalId__c;
        }

        fields = new Map<String, String> {};
        for (String fld : fieldsToSelect) {
            String value = '';
            if (ct != null && ct.get(fld) != null) value = String.valueOf(ct.get(fld));
            fields.put(fld, value);
        }
    }
    public void saveMe() {
        try {
            RecordType accRt = [SELECT Id FROM RecordType WHERE Name = 'Russian Sales' AND SobjectType = 'Lead' LIMIT 1];
            Lead ct = new Lead(PD_ExternalId__c = externalId, PD_Avaliable_LastName_Update__c = true, RecordTypeId = accRt.Id); //comment PD_ExternalId to switch off
            for(String fld : fields.keySet()) {
                ct.put(fld, fields.get(fld));
            }
                    
            putPhoneFieldsValues (ct);
            ct.put('Additional_Phones__c', getAdditionalPhonesValue ());
            putDescription (ct);
            if (leadId == null) {
                insert ct;
                leadId = ct.Id;
                this.recordCreated = true;
            } else {
                ct.Id = leadId;
                update ct;
                this.recordUpdated = true;
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return;
        }
    }
    // --- finish editing for classic ---
    public PageReference openRecord() {
        Lead newRecord = new Lead (Id = leadId);
         if (this.recordCreated) {
            PageReference editPage = new ApexPages.StandardController(newRecord).edit();
            editPage.setRedirect(true);
            PageReference viewPage = new ApexPages.StandardController(newRecord).view();
            editPage.getParameters().put('retURL', viewPage.getURL());
            return editPage;
        } else {
            PageReference viewPage = new ApexPages.StandardController(newRecord).view();
            viewPage.setRedirect(true);
            return viewPage;
        }
    }
    // --- finish editing for lightning ---
    public PageReference rerenderPage() {
        Boolean finishedEditing = false;
        if (this.recordCreated || this.pdDataSaved) {
            Lead newLead = [SELECT Id, Source_of_Lead__c FROM Lead WHERE Id = :leadId];
            finishedEditing = newLead.Source_of_Lead__c != null;
        } else if (this.recordUpdated) {
            finishedEditing = true;
        }
        if (finishedEditing) {
            PageReference viewPage = new ApexPages.StandardController(new Lead (Id = leadId)).view();
            viewPage.setRedirect(true);
            return viewPage;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.exception_pd_FinishEditingRecord));
        return null;
    }
    public PageReference closePage() {
            return new PageReference ('/apex/PD_Lead?id=' + leadId + '&pdDataSaved=true');
    }
}