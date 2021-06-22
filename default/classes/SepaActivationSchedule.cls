public class SepaActivationSchedule implements Schedulable, Database.AllowsCallouts {


    /*******************************************************************************
	*  Summary         : Execute scheduled logic (0 30 * ? * ?)
	*  CreatedDate     : 06/10/2020 by Anton Buzak
	*  Parameters      : sc - object to keep track of the scheduled job once it's scheduled
	*  Returns         : void
	******************************************************************************/
    public void execute(SchedulableContext sc) {
        ExecuteQueue queue = new ExecuteQueue();
        System.enqueueJob(queue);
    }


    public class ExecuteQueue implements Queueable, Database.AllowsCallouts {


        /*******************************************************************************
        *  Summary         : Execute queue logic
        *  CreatedDate     : 30/11/2020 by Anton Buzak
        *  Parameters      : -
        *  Returns         : void
        ******************************************************************************/
        public void execute(QueueableContext context) {
            try {
                Twikey__c twikeySettings;
                Twikey__c twikeySettingsTest = Twikey__c.getInstance('Test');
                Twikey__c twikeySettingsProd = Twikey__c.getInstance('Production');
                if (twikeySettingsProd != null && twikeySettingsProd.Active__c == true) {
                    twikeySettings = twikeySettingsProd;
                } else if (twikeySettingsTest != null && twikeySettingsTest.Active__c == true) {
                    twikeySettings = twikeySettingsTest;
                }

                SepaWebTwikey sepaWebTwikey = new SepaWebTwikey();
                TwikeyEntity twikeyFeedEntity = sepaWebTwikey.updateFeed(twikeySettings);

                if (twikeyFeedEntity.Messages != null) {
                    SepaActivationBatch batch = new SepaActivationBatch(twikeySettings, twikeyFeedEntity);
                    Database.executeBatch(batch, 1);
                }
            }
            catch (Exception e) {
                ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
            }
        }
    }
}
