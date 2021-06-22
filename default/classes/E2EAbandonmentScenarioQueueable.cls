public with sharing class E2EAbandonmentScenarioQueueable implements Queueable, Database.AllowsCallouts {

    public List<Opportunity> listOpportunities;
/*
 Contact details                  --> activeStep == 0
  --------------------Case 1----------------------------------
 Company Details                  --> activeStep == 1, activeSubStep = 'Search company'
 Company Confirmation             --> activeStep == 1, activeSubStep = 'Another Tax ID'
 Fuel Consumption                 --> activeStep == 1, activeSubStep == 'Set total consumption'
 ---------------------Cas3 2----------------------------------
 Credit Offer                     --> activeStep == 1, activeSubStep = 'Calculating credit score'
 ---------------------Case 3----------------------------------
 Card Commercial Options          --> activeStep == 2, activeSubStep = 'Card configuration'
 Special Offer                    --> activeStep == 2, activeSubStep = 'Choosing offer'
 Card configuration (Technical )  --> activeStep == 2, activeSubStep = 'Technical parameters'
 ---------------------Case 4----------------------------------
 Value Added Services             --> activeStep == 3
 ---------------------Case 5----------------------------------
 Payment Options                  --> activeStep == 4, activeSubStep in 'DirectDebit' 'BankTransferDeposit' 'BankTransfer' 'DirectDebitDeposit'
 -------------------------------------------------------------
 Thank you for your order         --> activeStep == 4, activeSubStep = 'Congratulation'
*/
    public E2EAbandonmentScenarioQueueable(List<Opportunity> opportunities) {
        listOpportunities = opportunities;
    }

    /*******************************************************************************
    *  Name            : updateAbandonmentStatus
    *  Summary         : update on Opportunity e2e_Abandonment_Status from E2EAbandonmentScenarioBatch
    *  CreatedDate     : 24/04/2018
    *  Parameters      : (List<Opportunity> listOpportunities)
    *  Returns         : void
    ******************************************************************************/
    public void execute(QueueableContext qc) {
        try {
            List<User> e2eRuGuestUser = [
                    SELECT Id, Name
                    FROM User
                    WHERE Name = 'E2E RU Site Guest User'
                    LIMIT 1
            ];

            List<RecordType> russiaRecordType = [
                    SELECT id, name
                    FROM RecordType
                    WHERE Name = 'Russian Sales'
                    AND SobjectType = 'Opportunity'
            ];

            Set<Id> opportunityIds = new Set<Id>();
            for (Opportunity opportunity : listOpportunities) {
                opportunityIds.add(opportunity.Id);
            }

            Map<Id, E2EFormData__c> opportunityFormDataRelateMap = new Map<Id, E2EFormData__c>();
            for (E2EFormData__c formData : [
                    SELECT Id, E2E_Opportunity_Id__c, E2E_Manual_Entry__c, E2E_Manual_Entry_Legal_Info__c
                    FROM E2EFormData__c
                    WHERE E2E_Opportunity_Id__c IN :opportunityIds
                    LIMIT 1000
            ]) {
                opportunityFormDataRelateMap.put(formData.E2E_Opportunity_Id__c, formData);
            }

            Map<String, Opportunity> opportunitiesToUpdate = new Map<String, Opportunity>();
            List<Opportunity> opportunitiesForNotification = new List<Opportunity>();
            Map<String, E2E_Form_General_Settings__c> generalSettings = E2E_Form_General_Settings__c.getAll();
            List<OpportunityFieldHistory> history = [
                SELECT  OpportunityId, 
                        Field, 
                        NewValue, 
                        OldValue,
                        Opportunity.Account.BillingCountry,
                        CreatedDate
                FROM    OpportunityFieldHistory 
                WHERE   Field = 'Owner'
                AND     OpportunityId IN : opportunityIds AND 
                        Opportunity.RecordTypeId != :russiaRecordType.get(0).Id
                ORDER BY CreatedDate ASC
            ];
            Map<Id, OpportunityFieldHistory> historyMap = new Map<Id, OpportunityFieldHistory>();
            for(OpportunityFieldHistory opportunityChanging : history){
                if( !(historyMap.containsKey(opportunityChanging.OpportunityId) && 
                    opportunityChanging.CreatedDate < historyMap.get(opportunityChanging.OpportunityId).CreatedDate) &&
                    opportunityChanging.OldValue == generalSettings.get(opportunityChanging.Opportunity.Account.BillingCountry).Abandonment_User__c && 
                    opportunityChanging.NewValue != generalSettings.get(opportunityChanging.Opportunity.Account.BillingCountry).E2E_Guest_User_Id__c){
                        historyMap.put(opportunityChanging.OpportunityId, opportunityChanging);
                }
            }

            Map<String, String> opptyToE2EassistanceUserMap = new Map<String, String>();
            for (Opportunity opportunity : listOpportunities) {
                if (opportunity.RecordTypeId == russiaRecordType.get(0).Id) {
                    E2E_Abandonment_Scenario_Settings__c scenario_settings = E2E_Abandonment_Scenario_Settings__c.getInstance('RuAbandonScenario');

                    Datetime timeToAbandonAndEmail = Datetime.valueOf(opportunity.E2E_Last_Activity__c).addMinutes(Integer.valueOf(scenario_settings.TimeToAbandonAndEmail__c));
                    Datetime timeToManual = Datetime.valueOf(opportunity.E2E_Last_Activity__c).addMinutes(Integer.valueOf(scenario_settings.TimeToManual__c));

                    System.debug('HERE! ' + timeToAbandonAndEmail);
                    System.debug('HERE! ' + timeToManual);

                    if (system.now() > timeToManual && opportunity.E2E_Status__c == 'Клиент Активен') {
                        opportunity.E2E_Status__c = 'Клиент не активен';
                        opportunity.Business_process__c = GlobalUtils.BusinessProcessType.Standard.name();
                        if (!opportunitiesToUpdate.containsKey(opportunity.Id)) opportunitiesToUpdate.put(opportunity.Id, opportunity);
                    }

                    if (opportunity.IsClosed == false) {
                        //s
                        if (system.now() > timeToAbandonAndEmail) {
                            if (opportunity.E2E_Sub_Status__c != 'Автоматическое письмо' && opportunity.E2E_Sub_Status__c != 'Перевод в ручную обработку') {
                                opportunity.E2E_Sub_Status__c = 'Автоматическое письмо';
                                if (!opportunitiesToUpdate.containsKey(opportunity.Id)) opportunitiesToUpdate.put(opportunity.Id, opportunity);
                            }
                        } else if (system.now() > timeToManual) {
                            if (opportunity.E2E_Sub_Status__c != 'Перевод в ручную обработку') {
                                opportunity.E2E_Sub_Status__c = 'Перевод в ручную обработку';
                                opportunity.Business_process__c = GlobalUtils.BusinessProcessType.Standard.name();
                                if (!opportunitiesToUpdate.containsKey(opportunity.Id)) opportunitiesToUpdate.put(opportunity.Id, opportunity);

                                if (opportunity.E2E_Sales_Type__c != 'E2E с участием Inbound' && opportunity.OwnerId == e2eRuGuestUser.get(0).Id) {
									//Add to list for notifications
                                    opportunitiesForNotification.add(opportunity);
                                }
                            }
                        }
                    }

                    if (opportunity.E2E_Sub_Status__c == 'Перевод в ручную обработку' && opportunity.E2E_Sales_Type__c == 'Чистый e2e') {
                        opportunity.E2E_Sales_Type__c = 'Чистый e2e + помощь КЦ';
                        if (!opportunitiesToUpdate.containsKey(opportunity.Id)) opportunitiesToUpdate.put(opportunity.Id, opportunity);
                    }
                } else {
                    if(opportunity.Channel__c == 'POS' && opportunity.E2E_Active_Step__c == 0 && (opportunity.LeadSource == 'Tablet' || opportunity.LeadSource == 'QR Code' || opportunity.LeadSource == 'URL'))
                        continue;

                    Datetime timeToStart = Datetime.valueOf(opportunity.E2E_Last_Activity__c).addMinutes(30);
                    if (system.now()> timeToStart && opportunity.E2E_Status__c != 'Abandoned (hard)' && opportunity.E2E_Sub_Status__c != 'Marketing automation') {
                        E2E_Form_General_Settings__c settings = generalSettings.get(opportunity.account.BillingCountry);
                        if (opportunity.E2E_Manual_Adoption_Date__c == null) {
                            if (settings != null && settings.Abandonment_User__c != null) {
                                if (! historyMap.isEmpty() && historyMap.get(opportunity.Id) != null && settings.Abandonment_User__c.equals(String.valueOf(historyMap.get(opportunity.Id).OldValue).substring(0, 15))) {
                                    opportunity.OwnerId = String.valueOf(historyMap.get(opportunity.Id).NewValue);
                                } else {
                                    opportunity.OwnerId = settings.Abandonment_User__c;
                                }
                            }
                        } else {
                            if (opportunity.E2E_Assistant__c != null) {
                                opptyToE2EassistanceUserMap.put(opportunity.Id, opportunity.E2E_Assistant__c);
                            }
                        }
                        opportunity.E2E_Status__c = 'Abandoned (hard)';
                        opportunity.E2E_Sub_Status__c = 'Marketing automation';
                        opportunitiesToUpdate.put(opportunity.Id, opportunity);
                    }
                }
            }
            if (opportunitiesToUpdate.size() != 0) {
                if (opptyToE2EassistanceUserMap.size() != 0) {
                    Map<String, User> e2eAssistantUsersMap = returnAssistantUsers(opptyToE2EassistanceUserMap.values());
                    List<Messaging.SingleEmailMessage> messagesToE2EAssistant = new List<Messaging.SingleEmailMessage>();
                    for (String oppId : opptyToE2EassistanceUserMap.keySet()) {
                        opportunitiesToUpdate.get(oppId).OwnerId = e2eAssistantUsersMap.get(opptyToE2EassistanceUserMap.get(oppId)).Id;
                        Messaging.SingleEmailMessage msg = generateEmailToE2EAssistant(opportunitiesToUpdate.get(oppId), e2eAssistantUsersMap.get(opptyToE2EassistanceUserMap.get(oppId)));
                        messagesToE2EAssistant.add(msg);
                    }
                    if (! Test.isRunningTest()) {
                        Messaging.sendEmail(messagesToE2EAssistant);
                    }
                }
                update opportunitiesToUpdate.values();
            }
			//Send email notifications
            E2E_RU_Internal_Notifications.abandonmentScenarioQueueable(opportunitiesForNotification, opportunityFormDataRelateMap);

        } catch (Exception e) {
            String notificationMessage = '<br/>E2EAbandonmentScenario Exception: E2EAbandonmentScenarioQueueable ' + String.valueOf(e.getMessage());
            ExceptionLogger.sendException(notificationMessage, String.valueOf(e.getStackTraceString()));
        }

         
    }


    private Map<String, User> returnAssistantUsers(List<String> userNamesList) {
        List<User> e2eAssistantsList = [SELECT Id, Name, Email FROM User WHERE Name IN :userNamesList LIMIT 1000];
        Map<String, User> assistantUsersMap = new Map<String, User>();
        for (User user : e2eAssistantsList) {
            assistantUsersMap.put(user.Name, user);
        }
        return assistantUsersMap;
    }


    private Messaging.SingleEmailMessage generateEmailToE2EAssistant(Opportunity oppty, User assistanceUser) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[] { assistanceUser.Email });
        message.setSubject('Abandoned E2E process.');
        message.setHtmlBody('This client has abandoned the e2e process. Please check it: <a href="https://fleetcor-eu.my.salesforce.com/' + oppty.Id + '" target="_blank">' + oppty.Name + '</a>');
        return message;
    }
}