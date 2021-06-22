public with sharing class PD_MetaDataCacheController {

    PD_SFMetaApi metaApi;
    Map<Id, ApiProfile> profileNames = new Map<Id, ApiProfile>();
    Map<Id, ApiLayout> apiLayouts = new Map<Id, ApiLayout>();

    public String profileNamesJSON {get; private set;}
    public String layoutsJSON {get; private set;}

    public String result {get; private set;}
    public PD_MetaDataCacheController() {
        metaApi = new PD_SFMetaApi();
        result = '{}';
        prepareProfiles();
        prepareLayouts();
    }

    private void prepareProfiles(){
        PD_XPath xp = new PD_XPath(metaApi.listMeta('Profile'));
        Dom.XmlNode[] nodes = xp.find('soapenv:Body/listMetadataResponse/result/fullName');

        Map<Id, Profile> profiles = new Map<Id, Profile>([select Id, Name from Profile]);

        Map<Id, String> profileNamesMap = new Map<Id, String>();
        for (Dom.XmlNode node:nodes) {
            String id = xp.find(node.getParent(), 'id')[0].getText();
            profileNames.put(id, new ApiProfile(id, profiles.get(id).Name, node.getText()));
            profileNamesMap.put(id, node.getText());
        }
        profileNamesJSON = JSON.serialize(profileNamesMap);
    }

    private void prepareLayouts(){
        PD_XPath xp = new PD_XPath(metaApi.listMeta('Layout'));
        Dom.XmlNode[] nodes = xp.find('soapenv:Body/listMetadataResponse/result/fullName');

//        Personal_Data_Objects__c objectsSetting = Personal_Data_Objects__c.getValues('objects');
//        if (objectsSetting == null) {
//            throw new PDException(Label.pd_mapping_types_not_defined);
//        }
//        String objects = String.valueOf(objectsSetting.Objects__c);
//        if (String.isEmpty(objects)) {
//           throw new PDException(Label.pd_mapping_types_not_defined);
//        }

        String objects = 'Lead,Contact';
        Set<String> usedObjectNames = new Set<String>();
        for (String objname:objects.split(',')) {
            objname = objname.trim();
            usedObjectNames.add(objname);
            if (objname == 'Account') {
                usedObjectNames.add('PersonAccount');
            }
        }

        if (usedObjectNames.size() == 0) {
            return;
        }

        Map<Id, String> apiLayoutsMap = new Map<Id, String>();
        for (Dom.XmlNode node:nodes) {
            String fullName = node.getText();
            String objectName = fullName.substringBefore('-');
            String layoutName = fullName.substringAfter('-');
            String id = xp.find(node.getParent(), 'id')[0].getText();
            Dom.XmlNode[] nsNodes = xp.find(node.getParent(), 'namespacePrefix');
            String ns = '';
            if (nsNodes.size() > 0) {
                ns = nsNodes[0].getText();
                if (!String.isEmpty(ns)){
                    ns += '__';
                }
            }

            Boolean ok = usedObjectNames.contains(objectName) || usedObjectNames.contains(ns+objectName);
            if (usedObjectNames.contains(ns+objectName)) {
                fullName = ns+objectName + '-' + ns + layoutName;
                objectName = ns+objectName;
            } else if (usedObjectNames.contains(objectName)) {
                fullName = objectName + '-' + ns + layoutName;
            }
            if (ok) {
                apiLayouts.put(id, new ApiLayout(id, fullName, objectName, objectName + '.' + EncodingUtil.urlDecode(layoutName, 'UTF-8')));
                apiLayoutsMap.put(id, fullName);
            }
            layoutsJSON = JSON.serialize(apiLayoutsMap);
        }
    }

    public ApiProfile[] getProfileApiList() {
        return profileNames.values();
    }

    public ApiLayout[] getLayoutList() {
        return apiLayouts.values();
    }

    @RemoteAction
    public static String fillProfilesCache2(String profileId, String profileName) {
        String result;
        PD_SFMetaApi metaApi = new PD_SFMetaApi();
        try {
            String profileXML = metaApi.readMeta('Profile', new String[]{profileName});
            String recordTypeVisibilities = '<recordTypeVisibilities>' + profileXML.substringAfter('<recordTypeVisibilities>').substringBeforeLast('</recordTypeVisibilities>') + '</recordTypeVisibilities>';
            String layoutAssignments = '<layoutAssignments>' + profileXML.substringAfter('<layoutAssignments>').substringBeforeLast('</layoutAssignments>') + '</layoutAssignments>';
            profileXML = '<?xml version="1.0" encoding="UTF-8"?>\n<profile>' + recordTypeVisibilities + layoutAssignments + '</profile>';
            PD_Cache__c c = new PD_Cache__c (
                    key__c = 'Profile.' + profileId,
                    value__c = profileXML,
                    value2__c = profileXML 
            );
            upsert c key__c;
            result = '{"id":"' + profileId + '", "result":"Success"}';
        } catch (Exception e) {
            result = '{"id":"' + profileId + '", "result":"Error";"message":"' + e.getMessage() + '"}';
        }
        return result;
    }

    @RemoteAction
    public static String fillLayoutsCache2(String layoutId, String layoutName) {
        String result;
        PD_SFMetaApi metaApi = new PD_SFMetaApi();
        try {
            String layoutXML = metaApi.readMeta('Layout', new String[]{layoutName});
            PD_Cache__c c = new PD_Cache__c (
                    key__c = 'Layout.' + layoutName,
                    value__c = layoutXML,
                    value2__c = layoutXML 
            );
            upsert c key__c;
            result = '{"id":"' + layoutId + '", "result":"Success"}';
        } catch (Exception e) {
            result = '{"id":"' + layoutId + '", "result":"Error", "message":"' + e.getMessage() + '"}';
        }
        return result;
    }

    public class ApiProfile {
        public String name{get; set;}
        public String apiName{get; set;}
        public String id{get; set;}
        public ApiProfile(String i, String n, String an) {
            id = i;
            name = n;
            apiName = an;
        }
    }

    public class ApiLayout {
        public String name{get; set;}
        public String objName{get; set;}
        public String id{get; set;}
        public String displayname{get; set;}

        public ApiLayout(String i, String n, String objn, String displayName) {
            id = i;
            name = n;
            objName = objn;
            this.displayname = displayname;
        }
    }
}