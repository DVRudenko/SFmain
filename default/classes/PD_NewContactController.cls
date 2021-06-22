public class PD_NewContactController extends PhoneNumbersControllerHelper {

    public Map<String, String> fields {get;set;}

    public String externalId {get;set;}
    public String PD_Token {get; set;}
    public String PD_URL {get; set;}
    public Boolean PD_IsActive {get; set;}
    public String birthdateSTR {get; set;}

    public String accountId {get {return accountId == '' ? null : accountId;} set;}
    public String opportunityId {get {return opportunityId == '' ? null : opportunityId;} set;}

    public Id contactId {get;set;}
    public Boolean recordCreated{get{return recordCreated == null ? false : recordCreated;} set;}
    public Boolean recordUpdated{get{return recordUpdated == null ? false : recordUpdated;} set;}
    public Boolean pdDataSaved {get;set;} // for Lighning redirect to edit page
    public Boolean finishedEditing {get;set;}

    private void init() {
        this.pdDataSaved = ApexPages.currentPage().getParameters().get('pdDataSaved') == 'true';
        this.accountId = ApexPages.currentPage().getParameters().get('accountid');
        this.opportunityId = ApexPages.currentPage().getParameters().get('oppid');
        PD_Setting__c mc = PD_Setting__c.getOrgDefaults();
        PD_Token = mc.Token__c;
        PD_URL = mc.URL__c;
        PD_IsActive = mc.IsActive__c;
        if (PD_Token == null) throw new PD_Exception('Token is empty'); //PD logic switch on-off
    }

    public PD_NewContactController(ApexPages.StandardSetController stdController) {
        init();
    }

    public PD_NewContactController(ApexPages.StandardController stdController) {
        init();
        contactId = stdController.getId();  
        if (this.pdDataSaved) {
            Contact newContact = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
            this.finishedEditing = newContact.AccountId != null;
            if (!finishedEditing) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.notif_pd_PDDataWasSaved));
            }
        }

        Boolean isNewRecord = contactId == null;
        initPhones (isNewRecord, Schema.Contact.sObjectType, stdController);

        String[] fieldsToSelect = new String[]{};
        List<Schema.FieldSetMember>  pdFields = GlobalUtils.getFieldSetMembers (Schema.Contact.sObjectType, 'PD_Fields');
        for (Schema.FieldSetMember pdField : pdFields) {
            fieldsToSelect.add(pdField.getFieldPath());
        }

        Contact ct = null;
        if (contactId != null) {
            fieldsToSelect.add('Id');
            String query = 'SELECT ' + String.join(fieldsToSelect, ',') + ', PD_ExternalId__c FROM Contact WHERE Id = \'' + contactId + '\'';
            ct = Database.query(query);
            externalId = ct.PD_ExternalId__c;
        }

        fields = new Map<String, String> {};
        for (String fld : fieldsToSelect) {
            String value = '';
            if (ct != null && ct.get(fld) != null) {
                value = String.valueOf(ct.get(fld));
                if (fld == 'Birthdate') {
                    value = String.valueOf((Date)ct.get(fld));
                    birthdateSTR = value;
                }
            }

            fields.put(fld, value);
        }
    }
    public void saveMe() {
        try {
            RecordType accRt = [SELECT Id FROM RecordType WHERE Name = 'Russian' AND SobjectType = 'Contact' LIMIT 1];
            Contact ct = new Contact(PD_ExternalId__c = externalId, PD_Avaliable_LastName_Update__c = true,  //comment PD_ExternalId to switch off
                                    RecordTypeId = accRt.Id,
                                    AccountId = this.accountId);
            for(String fld : fields.keySet()) {
                if (fld == 'Birthdate') {
                    if (!String.isEmpty(birthdateSTR)) {
                        String[] dateField = birthdateSTR.split('-');
                        Date birthdate = Date.newinstance(Integer.valueOf(dateField[0]), Integer.valueOf(dateField[1]), Integer.valueOf(dateField[2]));
                        ct.put(fld, birthdate);
                    } else {
                        ct.put(fld, null);
                    }
                } else {
                    ct.put(fld, fields.get(fld));
                }
            }
            putPhoneFieldsValues (ct);
            ct.put('Additional_Phones__c', getAdditionalPhonesValue ());
            putDescription (ct);
            if (contactId == null) {
                insert ct;
                contactId = ct.Id;
                this.recordCreated = true;
                
                if (this.opportunityId != null) {
                // if contact was created from an opportunity and the opportunity doesn't have a primary contact then make this contact as primary
                    List <OpportunityContactRole> oppContactRoles = [SELECT id, IsPrimary, ContactId FROM OpportunityContactRole 
                                                                    WHERE OpportunityId =:this.opportunityId 
                                                                    AND (IsPrimary = true OR ContactId =:contactId)
                                                                    ORDER BY IsPrimary DESC
                                                                   ]; // primary contact roles first
                    if (oppContactRoles.isEmpty()) {
                        createPrimaryContactRoleForOpp (this.opportunityId, contactId);
                    } else if (oppContactRoles[0].IsPrimary == false) { // no primary contacts
                        OpportunityContactRole ocr_toUpdate;
                        for (OpportunityContactRole oppContactRole : oppContactRoles) {
                            if(oppContactRole.ContactId == contactId) {
                                oppContactRole.IsPrimary = true;
                                ocr_toUpdate = oppContactRole;
                            }
                        }
                        if (ocr_toUpdate != null) update ocr_toUpdate;
                    }
                }
            } else {
                ct.Id = contactId;
                update ct;
                this.recordUpdated = true;
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return;
        }
    }
    // create a contact role by opportunity and contact ids
    private void createPrimaryContactRoleForOpp (Id oppId, Id conId) {
        OpportunityContactRole ocr = new OpportunityContactRole(
            ContactId = conId,
            OpportunityId = oppId,
            IsPrimary = true
        );
        insert ocr;
    }
    
    // --- finish editing for classic ---
    public PageReference openRecord() {
        Contact newRecord = new Contact (Id = contactId);
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
            Contact newContact = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
            finishedEditing = newContact.AccountId != null;
        } else if (this.recordUpdated) {
            finishedEditing = true;
        }
        if (finishedEditing) {
            PageReference viewPage = new ApexPages.StandardController(new Contact (Id = contactId)).view();
            viewPage.setRedirect(true);
            return viewPage;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.exception_pd_FinishEditingRecord));
        return null;
    }
    public PageReference closePage() {
            return new PageReference ('/apex/PD_Contact?id=' + contactId + '&pdDataSaved=true');
    }
}