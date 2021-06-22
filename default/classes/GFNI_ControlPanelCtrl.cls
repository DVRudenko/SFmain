/**
 * Created by Nikita.Mikhailov on 19.03.2019.
 */

public with sharing class GFNI_ControlPanelCtrl {
    public List<String> countryList { get; set; }

    public Map<String, Boolean> countryIsForRobotMap { get; set; }

    public String idValue { get; set; }
    public String response {
        get {
            if (response == null)
                response = '';

            return this.response;
        }
        set;
    }

    public void init() {
        this.countryIsForRobotMap = new Map<String, Boolean>();
        this.countryList = new List<String>();


        Map<String, GFNI_General_Settings__c> gfni_general_settings = GFNI_General_Settings__c.getAll();
        for (String key : gfni_general_settings.keySet()) {
            this.countryList.add(key);
            this.countryIsForRobotMap.put(key, gfni_general_settings.get(key).IsForRobot__c);
        }
    }

    public void onApplyButtonClick() {
        Map<String, GFNI_General_Settings__c> gfni_general_settings = GFNI_General_Settings__c.getAll();
        List<GFNI_General_Settings__c> listOfSettingsToUpdate = new List<GFNI_General_Settings__c>();
        for (String country : countryIsForRobotMap.keySet()) {
            GFNI_General_Settings__c updatingSetting = gfni_general_settings.get(country);
            if (updatingSetting.IsForRobot__c != countryIsForRobotMap.get(country)) {
                updatingSetting.IsForRobot__c = countryIsForRobotMap.get(country);
                listOfSettingsToUpdate.add(updatingSetting);
            }
        }

        if (!listOfSettingsToUpdate.isEmpty()) {
            update listOfSettingsToUpdate;
            init();
        }
    }

    public void onCheckButtonClick() {
        if (String.isBlank(this.idValue)) {
            this.response = '{ "ERROR" : "No value provided." }';
            System.debug(this.response);
            return ;
        }

        Opportunity opportunity;
        try {
            opportunity = [SELECT Id, CreatedDate, GFNI_ApplicationId__c, Account.BillingCountry, Account.BillingCountryCode FROM Opportunity WHERE Id = :idValue];
        } catch (Exception e) {
            this.response = '{ "ERROR" : "' + e.getMessage() + ' ' + e.getStackTraceString() + '", "Line" : "' + e.getLineNumber() + '"}';
            System.debug(this.response);
            return ;
        }

        if (opportunity == null) {
            this.response = '{ "ERROR" : "Opportunity not found."}';
            System.debug(this.response);
            return ;
        }

        String applicationStatusRequest = GFNI_RequestBuilder.buildJSONApplicationStatus(new List<Opportunity>{
                opportunity
        });

        HttpResponse response;

        try {
            response = GFNI_RequestHandler.sendRequest(applicationStatusRequest, GFNI_Utils.getGeneralSettings(opportunity.Account.BillingCountryCode).Application_Status__c, opportunity.Account.BillingCountryCode);
        } catch (Exception e) {
            this.response = '{ "ERROR" : "' + e.getMessage().replaceAll('"', '').replaceAll('\'', '').replaceAll('\\n', '') + ' ' + e.getStackTraceString().replaceAll('\\n', '') + '", "Line" : "' + e.getLineNumber() + '"}';
            System.debug(this.response);
            return ;
        }

        this.response = response.getBody();
        System.debug(this.response);
    }
}