public with sharing class PD_PageLayout {
    PD_XPath layoutXp;
    SObject obj;
    String name;

    public LayoutSection[] layoutSections;
    
    public PD_PageLayout (SObject obj, String layoutName) {
        this.obj = obj;
        name = layoutName;
    }

    public LayoutSection[] getLayoutSections () {
        String layoutData = PD_Cache.get('Layout.' + name);
        if (String.isEmpty(layoutData)) {
            throw new PD_Exception('Can\'t read layout data. Please, contact your Salesforce Administrator.');
        }
        
        layoutXp = new PD_XPath(layoutData);
        Dom.XmlNode[] nodes = layoutXp.find('soapenv:Body/readMetadataResponse/result/records/layoutSections');
        layoutSections = new LayoutSection[]{};
        for (Dom.XmlNode node:nodes) {
            LayoutSection ls = new LayoutSection(obj, node, layoutXp);
            if (ls.style != 'CustomLinks' && ls.objectFields.size() > 0) {
                layoutSections.add(ls);
            }
        }
        return layoutSections;
    }

    public class LayoutSection {
        public String label {get; private set;}
        public Integer columnsNum {get; private set;}
        public SectionField[] objectFields {get; private set;}
        public String  style {get; private set;}
        private SObject obj;

        public LayoutSection(SObject obj, Dom.XMLNode node, PD_XPath xp) {
            objectFields = new SectionField[]{};
            this.obj = obj;
            label = xp.getText(node, 'label');
            style = xp.getText(node, 'style');
            Dom.XmlNode[] columnNodes = xp.find(node, 'layoutColumns');
            columnsNum = columnNodes.size();
            List<SectionField[]> columns = new List<SectionField[]>();
            Integer maxFields = 0;
            Boolean explodeName = obj.getSObjectType().getDescribe().getName() == 'Account' || obj.getSObjectType().getDescribe().getName() == 'Contact';
            Boolean isLead = obj.getSObjectType().getDescribe().getName() == 'Lead';

            Map<String, Schema.SObjectField> objFieldsMap = obj.getSObjectType().getDescribe().fields.getMap();
            Map<String, Schema.SObjectField> objFieldsMapCorrected = new Map<String, Schema.SObjectField>();
            for (String kkk:objFieldsMap.keySet()) {
                objFieldsMapCorrected.put(objFieldsMap.get(kkk).getDescribe().getLocalName().toLowerCase(), objFieldsMap.get(kkk));
                system.debug(objFieldsMap.get(kkk).getDescribe().getLocalName().toLowerCase());
            }
system.debug(objFieldsMapCorrected);            
            for (Dom.XmlNode columnNode:columnNodes) {
                Dom.XmlNode[] layoutItems = xp.find(columnNode, 'layoutItems');
                if (layoutItems.size() == 0) {
                    continue;
                }
                SectionField[] colFieldnames = new SectionField[]{};
                columns.add(colFieldnames);
                for (Dom.XmlNode layoutItem:layoutItems) {
                    String field = xp.getText(layoutItem, 'field');
system.debug(field);
                    String behavior = xp.getText(layoutItem, 'behavior');
system.debug(behavior);
                    behavior = behavior != null ? behavior.toLowerCase() : null;
                    String empty = xp.getText(layoutItem, 'emptySpace');
                    if (behavior != null && (behavior == 'edit' || behavior == 'required')) {
                        if (field.contains('HubSpot_Inc__SICCode__c') || field.contains('PD_ExternalId') || field == 'RecordTypeId' || field == 'CampaignId') {
                        //if ((field.toLowerCase()).contains('external_personal_data_id') || field == 'RecordTypeId') { 
                            continue;
                        } else if (explodeName && field == 'Name') {
                            colFieldnames.add(new SectionField('FirstName', 'edit'));
                            colFieldnames.add(new SectionField('LastName', behavior));
                            //} else if (objFieldsMapCorrected.containskey(field.toLowerCase()) && objFieldsMapCorrected.get(field.toLowerCase()).getDescribe().getType() == Schema.DisplayType.ADDRESS) {
                        } else if (isLead && field == 'Name') {
                            colFieldnames.add(new SectionField('FirstName', 'edit'));
                            colFieldnames.add(new SectionField('MiddleName', 'edit'));
                            colFieldnames.add(new SectionField('LastName', behavior));
                        } else if (objFieldsMapCorrected.get(field.toLowerCase()).getDescribe().getType() == Schema.DisplayType.ADDRESS) {
                            String addressType = field.substringBefore('Address');
                            if (!String.isEmpty(addressType)) {
                                String[] subfields = new String[]{'CountryCode', 'StateCode', 'Street', 'City', 'PostalCode' };
                                for (String subField:subfields) {
                                    colFieldnames.add(new SectionField(addressType + subField, behavior));
                                }
                            }
                        } else {
                            colFieldnames.add(new SectionField(field, behavior));
                        }
                    } else if (empty != null && empty == 'true') {
                        colFieldnames.add(new SectionField());      
                    }
                }
                maxFields = Math.max(colFieldnames.size(), maxFields);
            }

            for (Integer k=0; k<maxFields; k++) {
                for (SectionField[] colFieldnames:columns) {
                    if (colFieldnames.size() > 0 && k < colFieldnames.size() && colFieldnames[k] != null) {
                        objectFields.add(colFieldnames[k]);
                    } else {
                        objectFields.add(new SectionField());
                    }
                }
            }
        }
    }

    public class SectionField {
        public String name {get; set;}
        public String behavior {get; set;}

        public Boolean required {get {return behavior=='required';}}
        public Boolean readonly {get {return behavior=='readonly';}}
        public Boolean empty {get {return behavior==null && name == null;}}

        public SectionField(String fieldName, String behavior) {
            this.name = fieldName;
            this.behavior = behavior;
        }
        
        public SectionField() {

        }
    }
}