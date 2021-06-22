abstract global with sharing class PD_RecordController {

    public PD_PageLayout.LayoutSection[] sections {get; protected set;}
    protected String objRecordTypeId {get; set;}
    protected String profileName;
    public String objectTypeName {get; protected set;}
    protected ApexPages.StandardController stdController {get; set;}
    protected Boolean isPersonAccount;
    public String PD_Token {get; set;}
    public String PD_URL {get; set;}
    
    global PD_RecordController (ApexPages.StandardController stdCon) {
        PD_Setting__c mc = PD_Setting__c.getOrgDefaults();
        PD_Token = mc.Token__c;
        PD_URL = mc.URL__c;
        if (PD_Token == null) throw new PD_Exception('Token is empty');
        stdController = stdCon;
        profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        //this is not good to rely on this param. 
        //it is better to rely on obj.Id, but we cant't as retrieving the obj will block an ability to add fields to stdController
        Id id = (Id)ApexPages.currentPage().getParameters().get('id'); 
        if (!String.isBlank(id)) {
            String[] requiredFields = new String[]{};
            Map<String, Schema.SObjectField> fields = id.getSobjectType().getDescribe().fields.getMap();
            for (String fieldName:fields.keySet()) {
                DescribeFieldResult fieldDesc = fields.get(fieldName).getDescribe();
//                requiredFields.add(fieldDesc.getName());
                requiredFields.add(fieldDesc.getLocalName());

            }
            requiredFields.add('Owner.Name');

            stdController.addFields(requiredFields);
        }
        
        objectTypeName = stdController.getRecord().getSObjectType().getDescribe().getName();
        setObj();
        setOwner();
        setRecordType();
        isPersonAccount = getIsPersonAccount();
        PD_PageLayout pl = new PD_PageLayout(getObj(), getAssignedPagelayout());
        sections = pl.getLayoutSections();
    }

    protected virtual void setObj(){}

    /**
    * Finds a Layout assigned to the current User for selected record type
    * @throws PDException
    * @return String
    **/
    public String getAssignedPageLayout() {
        String recordTypeName = [select DeveloperName from RecordType where Id=:objRecordTypeId].DeveloperName;
        String profileData = PD_Cache.get('Profile.' + UserInfo.getProfileId());
        system.debug('Profile.' + UserInfo.getProfileId());
        if (String.isEmpty(profileData)) { throw new PD_Exception('Can\'t read profile data. Please, contact your Salesforce Administrator.'); }
        system.debug(profileData);
        PD_XPath xp = new PD_XPath(profileData);
        Dom.XmlNode[] nodes = xp.find('layoutAssignments/recordType');
        String realObjectTypeName = objectTypename;
        if (objectTypename == 'Account' && isPersonAccount) { realObjectTypeName = 'PersonAccount'; }

        for (Dom.XmlNode node:nodes) {
            String nodeText = node.getText();
            if ((nodeText.endsWith(recordTypeName) || nodeText.endsWith('__'+recordTypeName)) 
                && (nodeText.substringBefore('.').endsWith(realObjectTypeName))) {
                return xp.getText(node.getParent(), 'layout');
            }
        }

        nodes = xp.find('layoutAssignments/layout');
        for (Dom.XmlNode node:nodes) {
            String nodeText = node.getText();
            if (nodeText.contains(realObjectTypeName)) { return nodeText; }
        }

        throw new PD_Exception('No layout for selected record type');
    }

    protected Id getRecordTypeId() {
        system.debug('call record type id');
        Id recTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        if (!String.IsEmpty(recTypeId)) {
            return recTypeId;
        }
        //find default rectype assign to the profile of the cerrent User;
        String profileData = PD_Cache.get('Profile.' + UserInfo.getProfileId());
        if (String.isEmpty(profileData)) { throw new PD_Exception('Can\'t read profile data. Please, contact your Salesforce Administrator.'); }
        PD_XPath xp = new PD_XPath(profileData);
        Dom.XmlNode[] nodes = xp.find('recordTypeVisibilities');

        for (Dom.XmlNode node:nodes) {
            String recordType = xp.getText(node, 'recordType');
            Boolean isVisible = xp.getText(node, 'visible') == 'true';
            Boolean isDefault = xp.getText(node, 'default') == 'true';
            if (isVisible && isDefault && (recordType.startsWith(objectTypeName + '.') || (objectTypeName == 'Account' && recordType.startsWith('PersonAccount.')))) {
                String dName = recordType.substringAfter('.');
                if (dName.contains('__')) { dName = dName.substringAfter('__'); }
                return [select Id from RecordType where DeveloperName = :dName and SObjectType = :objectTypeName].Id;
            }
        }

        //find any rectype available 
        RecordType[] rectypes = [select Id from RecordType where SObjectType=:objectTypeName limit 1];
        if (rectypes.size() > 0) {
            return rectypes[0].Id;
        }
        return null;
    }

    public String  getPageTitle(){
        return (!getIsNew() ? Label.pd_edit : Label.pd_new) + ' ' + objectTypeName;
    }

    public virtual SObject getObj() {
        return null;
    }

    public virtual Boolean getIsNew() {
        return getObj().Id == null;
    }

    public virtual PageReference saveMe() {
        SObject obj = getObj();
        try {
            if (obj.Id == null) {
                insert obj;
            } else { update obj; }

        } catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }

        return new PageReference('/' + obj.Id);
    }

    protected virtual void setRecordType(){
        SObject sobj = getObj();
        if (sobj.Id == null) {
            Id recType = getRecordTypeId();
            if (recType != null) {
                sobj.put('RecordTypeId', recType);
                objRecordTypeId = (Id)sobj.get('RecordTypeId');
            }
        } else { objRecordTypeId = (Id)sobj.get('RecordTypeId'); }
    }

    protected Boolean getisPersonAccount() {
        return true;
//        return [select IsPersonType from RecordType where id=:objRecordTypeId].IsPersonType;
    }

    protected virtual void setOwner(){}
 }