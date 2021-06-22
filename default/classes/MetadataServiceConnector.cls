public without sharing class MetadataServiceConnector {
     /*****************************************************************************
    *  Name            : getStandardPicklistTranslations
    *  Author          : Svetlana Grecheva
    *  Summary         : Returns map of standard picklist translations
    *  CreatedDate     : 30.10.2020
    *  Parameters      : String standardValueSetTranslationName - name of StandardValueSetTranslation metadata type
    *  Returns         : Map <String, String> - map picklist label => picklist translation
    *  Example         : getStandardPicklistTranslations ('LeadStatus-ru');
    */
    public static Map <String, String> getStandardPicklistTranslations (String standardValueSetTranslationName) {
        Map <String, String> ret = new Map <String, String>();
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        MetadataService.StandardValueSetTranslation picklistTransl = (MetadataService.StandardValueSetTranslation) service.readMetadata(
            'StandardValueSetTranslation', new String[] {standardValueSetTranslationName}
        ).getRecords()[0];
        if (picklistTransl.valueTranslation.isEmpty()) return ret;
        for(MetadataService.ValueTranslation valueTranslation : picklistTransl.valueTranslation) {
            if (valueTranslation.translation != '') {
                ret.put(valueTranslation.masterLabel, valueTranslation.translation);
            }
        }
        return ret;
    }
}
