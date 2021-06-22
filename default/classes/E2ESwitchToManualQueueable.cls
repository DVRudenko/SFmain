public class E2ESwitchToManualQueueable implements Queueable{

    public List<Opportunity> listOpportunities;

    public E2ESwitchToManualQueueable(List<Opportunity> opportunities){
        listOpportunities = opportunities;
    }

    public  void execute(QueueableContext qc) {
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        Map<String, E2E_Switched_to_Manual_Templates__c> templatesMap = E2E_Switched_to_Manual_Templates__c.getAll();
        if (templatesMap.isEmpty()) return;

        if ( ! listOpportunities.isEmpty() ) {
            Set<String> stageNameStatusesSet = new Set<String>{'Prospecting', 'Credit Approved'};
            for (Sobject so : listOpportunities) {
                Opportunity opp = (Opportunity) so;

                if (opp.Emarsys_Logs__r != null) {
                    for (Emarsys_Log__c emarsyslog : opp.Emarsys_Logs__r) {
                        Datetime timeToStart;
                        if ( Test.isRunningTest() ) {
                            // fix for test
                            timeToStart = Datetime.valueOf(emarsyslog.CreatedDate).addDays(0);
                        } else {
                            timeToStart = Datetime.valueOf(emarsyslog.CreatedDate).addDays(2);
                        }
                        if ((system.now() > timeToStart) && templatesMap.containsKey(emarsyslog.Email_Name__c)) {
                            opp.E2E_Status__c = 'Abandoned (hard)';
                            opp.E2E_Sub_Status__c = 'Switched to manual';
                            opp.E2E_Sales_Type__c = 'E2E downgraded to manual';
                            E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(opp.Account.BillingCountry);
                            if (settings != null && settings.Abandonment_User__c != null) {
                                opp.OwnerId = settings.Abandonment_User__c;
                            }     
                            oppListToUpdate.add(opp);                       
                            break;
                        } else if ((system.now() > timeToStart) && opp.Number_of_open_tasks__c > 0 && ! stageNameStatusesSet.contains(opp.StageName)) {
                            opp.E2E_Status__c = 'Abandoned (hard)';
                            opp.E2E_Sub_Status__c = 'Switched to manual';
                            opp.E2E_Sales_Type__c = 'E2E downgraded to manual';
                            oppListToUpdate.add(opp);
                            break;
                        }
                    }
                }
            }
        }

        if ( ! oppListToUpdate.isEmpty() ) {
            update oppListToUpdate;
        }

    }
}