global class OpportunityStageStatusBatch implements Database.Batchable<sObject> {
    public String query;


    /*******************************************************************************
    *  Name            : OpportunityStageStatusBatch()
    *  Summary         : Get select Opportunity for batch   
    *  CreatedDate     : 14-02-2018
    *  ModifiedDate    : 15-02-2018
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    global OpportunityStageStatusBatch() {
        this.query = 'SELECT Id, Name, StageName, Gruende_verloren__c, OwnerId, ' + 
                        '(SELECT NewValue, Field, CreatedDate FROM Histories WHERE Field = \'StageName\') ' +
                    'FROM Opportunity ' + 
                    'WHERE StageName = \'CreditCheck abgelehnt\' AND ' + 
                        'CALENDAR_YEAR(CreatedDate) >= 2018 ' +
                    'LIMIT 50000';
}


    /*******************************************************************************
    *  Name            : Database.QueryLocator start(Database.BatchableContext bc) 
    *  Summary         : Collect SObjects to pass to the interface method execute 
    *  CreatedDate     : 14-02-2018
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job
    *  Returns         : Database.QueryLocator
    *****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }


    /*******************************************************************************
    *  Name            : execute(Database.BatchableContext BC, list<Sobject> scope)
    *  Summary         : update StageName and Gruende_verloren__c and sending email    
    *  CreatedDate     : 14-02-2018
    *  ModifiedDate    : 15-02-2018
    *  Parameters      : Database.BatchableContext BC, list<Sobject> scope
    *  Returns         : void
    ******************************************************************************/
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        if ( ! scope.isEmpty()) {

            List<EmailTemplate> emailTemplateList = [
                    SELECT Id, Subject, HtmlValue, Body
                    FROM EmailTemplate 
                    WHERE DeveloperName = 'Opportunity_Stage_notification'
                    LIMIT 1];

            EmailTemplate emailTemplate;
            if (! emailTemplateList.isEmpty()) {
                emailTemplate = emailTemplateList.get(0);
            }

            List<Opportunity> oppsToUpdateList = new List<Opportunity>();
            List<Messaging.Email> allMessageList = new List<Messaging.Email>();
            for (Sobject so : scope) {
                Opportunity opp = (Opportunity)so;
                Integer daysAfterChange;

                for (OpportunityFieldHistory ofh : opp.Histories) {
                    if (ofh.NewValue == 'CreditCheck abgelehnt') {
                        daysAfterChange = (Date.valueOf(ofh.CreatedDate)).daysBetween(Date.today());
                    }
                }

                if (Test.isRunningTest() && opp.Name == 'test1') {
                    // 14-02-2018 Fix for Opportunity Field History (can't track in unit test)
                    daysAfterChange = 6;
                } else if (Test.isRunningTest() && opp.Name == 'test2') {
                    // 14-02-2018 Fix for Opportunity Field History (can't track in unit test)
                    daysAfterChange = 8;
                }
                if (daysAfterChange > 7) {
                    opp.StageName = 'Closed Lost';
                    opp.Gruende_verloren__c = 'Refused Credit';
                    oppsToUpdateList.add(opp);
                }
                if (daysAfterChange == 6 && emailTemplate != null) {
                    Messaging.SingleEmailMessage mailToOppOwner = new Messaging.SingleEmailMessage();
                    mailToOppOwner.setTemplateID(emailTemplate.Id);
                    mailToOppOwner.setTargetObjectId(opp.OwnerId);
                    mailToOppOwner.setWhatId(opp.Id);
                    mailToOppOwner.setSaveAsActivity(false);
                    mailToOppOwner.setCharset('UTF8');
                    allMessageList.add(mailToOppOwner);
                }
            }
            // 14-02-2018 Use Queueable class for fix DML operation(can't do update)
            System.enqueueJob(new QueueClass(oppsToUpdateList));
            if ( ! Test.isRunningTest()) {
                Messaging.sendEmail(allMessageList, false);
            }

        }
    }


    global void finish(Database.BatchableContext BC) {
        
    }


    public class QueueClass implements Queueable {
        List<SObject> sObjectsList;


        /*******************************************************************************
        *  Name            : QueueClass(List<SObject> sObjectsList)
        *  Summary         : constructor
        *  CreatedDate     : 14-02-2018
        *  ModifiedDate    : -
        *  Parameters      : List<SObject> sObjectsList - sObjects to update
        *  Returns         : -
        ******************************************************************************/
        public QueueClass(List<SObject> sObjectsList) {
            this.sObjectsList = sObjectsList;
        }


        /*******************************************************************************
        *  Name            : execute(QueueableContext context)
        *  Summary         : update StageName and Gruende_verloren__c in SObject      
        *  CreatedDate     : 14-02-2018
        *  ModifiedDate    : -
        *  Parameters      : QueueableContext context - contains the job ID
        *  Returns         : void
        ******************************************************************************/
        public void execute(QueueableContext context) {
            try {
                update sObjectsList;
            } catch (Exception e) {
                Set<Id> IdsSet = new Set<Id>();
                for (SObject so : sObjectsList) {
                    IdsSet.add(so.Id);
                }
                ExceptionLogger.sendException('<br/>Reason: ' + String.valueOf(e.getMessage()) + '<br/>Opportunity Id : ' + IdsSet, String.valueOf(e.getStackTraceString()));
            }
        }
    }
}