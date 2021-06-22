public class OpportunityStartProcessCtrl {

    @AuraEnabled
    public static List<String> getListOfEditFields(){
        List<String> pageFields = new List<String>();
        for(Schema.FieldSetMember field : GlobalUtils.getFieldSetMembers(Schema.Opportunity.sObjectType, 'Start_Fields')){
            pageFields.add(String.valueOf(field.getSObjectField()));
        }
        return pageFields;
    }

    @AuraEnabled
    public static List<String> getListOfReadFields(){
        List<String> pageFields = new List<String>();
        for(Schema.FieldSetMember field : GlobalUtils.getFieldSetMembers(Schema.Opportunity.sObjectType, 'Start_Fields_read_only')){
            pageFields.add(String.valueOf(field.getSObjectField()));
        }
        return pageFields;
    }

}