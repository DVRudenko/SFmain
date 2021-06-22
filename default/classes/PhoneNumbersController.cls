public with sharing class PhoneNumbersController extends PhoneNumbersControllerHelper {
    public String PD_Token {get; set;}
    public String PD_URL {get; set;}
    public Boolean PD_IsActive {get; set;}
    public PhoneNumbersController(ApexPages.StandardController stdController) {
        Id sObjId = stdController.getId();
        init();
        initPhones (false, sObjId.getsObjectType(), stdController);
    }
    private void init() {
        PD_Setting__c mc = PD_Setting__c.getOrgDefaults();
        PD_Token = mc.Token__c;
        PD_URL = mc.URL__c;
        PD_IsActive = mc.IsActive__c;
        if (PD_Token == null) throw new PD_Exception('Token is empty'); //pd tmp switch off here
    }
}