public class SepaActivationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private Twikey__c twikeySettings;
    private TwikeyEntity twikeyFeedEntity;


    /*******************************************************************************
    *  Summary         : Constructor
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public SepaActivationBatch(Twikey__c twikeySettings, TwikeyEntity twikeyFeedEntity) {
        this.twikeySettings = twikeySettings;
        this.twikeyFeedEntity = twikeyFeedEntity;
    }


    /*******************************************************************************
    *  Summary         : Call this method for each batch of records.
    *  CreatedDate     : 02/07/2019
    *  ModifiedDate    : -
    *  Parameters      : Database.BatchableContext bc - object for tracking the progress of the batch job,
                         List<Opportunity> opportunitiesList - list of Opportunities to process
    *  Returns         : void
    ******************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> mandateIdsSet = new Set<String>();
        if (this.twikeyFeedEntity.Messages != null) {
            for (TwikeyEntity.Messages message : twikeyFeedEntity.Messages) {
                if (message.Mndt != null && message.Mndt.MndtId != null) {
                    mandateIdsSet.add(message.Mndt.MndtId);
                }
                else if (message.CxlRsn != null) {
                    mandateIdsSet.add(message.OrgnlMndtId);
                }
            }
        }

        String query =
                'SELECT Account.UMR__c, StageName, Mandate_Last_Modified_Date__c, Mandate_Activated__c, ' +
                        '(SELECT Id ' +
                        'FROM Attachments ' +
                        'WHERE Name = \'SEPAMandate\') ' +
                'FROM Opportunity ' +
                'WHERE Account.UMR__c IN :mandateIdsSet AND SEPA_Request_Approved__c = false';
        return Database.getQueryLocator(query);
    }


    /*******************************************************************************
    *  Summary         : Call this method for each batch of records.
    *  CreatedDate     : 06/10/2020 by Anton Buzak
    *  Parameters      : bc - object for tracking the progress of the batch job,
                         opportunitiesList - list of Opportunities to process
    *  Returns         : -
    ******************************************************************************/
    public void execute(Database.BatchableContext BC, List<Opportunity> opportunitiesList) {
        try {
            List<Opportunity> opportunitiesListToUpdate = new List<Opportunity>();
            List<Attachment> attachmentsToInsertList = new List<Attachment>();
            List<Attachment> attachmentsToDeleteList = new List<Attachment>();
            for (Opportunity opportunity : opportunitiesList) {
                TwikeyEntity.Messages lastMessage;
                String messageEventTime;
                for (TwikeyEntity.Messages message : twikeyFeedEntity.Messages) {
                    if (message.EvtTime != opportunity.Mandate_Last_Modified_Date__c && (
                            message.Mndt != null && message.Mndt.MndtId == opportunity.Account.UMR__c ||
                            message.CxlRsn != null && message.OrgnlMndtId == opportunity.Account.UMR__c) &&
                            (messageEventTime == null || message.EvtTime > messageEventTime)) {
                        messageEventTime = message.EvtTime;
                        lastMessage = message;
                    }
                }

                if (lastMessage != null) {
                    if (lastMessage.Mndt != null && lastMessage.Mndt.MndtId == opportunity.Account.UMR__c) {
                        opportunity.IBAN__c = lastMessage.Mndt.DbtrAcct;
                        if (lastMessage.Mndt.DbtrAgt != null && lastMessage.Mndt.DbtrAgt.FinInstnId != null) {
                            opportunity.SWIFT_BIC__c = lastMessage.Mndt.DbtrAgt.FinInstnId.BICFI;
                        }

                        opportunity.Send_SEPA_approval_link__c = true;
                        opportunity.SEPA_Request_Approved__c = true;
                        opportunity.Einwilligung_Lastschriftverfahren__c = true;
                        opportunity.AGB_Datenschutzhinweise_Richtigkeit__c = true;
                        if (opportunity.StageName == 'Closed Won') {
                            opportunity.Starts_Payment_method__c = 'Direct debit';
                        } else {
                            opportunity.Zahlungsart__c = 'Lastschrift';
                        }

                        if (lastMessage.EvtTime != null) {
                            opportunity.Mandate_Last_Modified_Date__c = lastMessage.EvtTime;
                            if (opportunity.Mandate_Activated__c == false) {
                                opportunity.SEPA_Request_Approval_Date__c = Datetime.valueOf(lastMessage.EvtTime.replace('T', ' ').replace('Z', ''));
                            }
                        }

                        opportunity.Mandate_Activated__c = true;
                        opportunitiesListToUpdate.add(opportunity);

                        SepaWebTwikey sepaWebTwikey = new SepaWebTwikey();
                        Blob pdfBody = sepaWebTwikey.retreivePdf(this.twikeySettings, lastMessage.Mndt.MndtId);
                        Attachment attachment = new Attachment(
                                ParentId = opportunity.Id,
                                Body = pdfBody,
                                Name = 'SEPAMandate');
                        attachmentsToInsertList.add(attachment);

                        if (! opportunity.Attachments.isEmpty()) {
                            attachmentsToDeleteList.add(opportunity.Attachments);
                        }
                    }
                    else if (lastMessage.CxlRsn != null && lastMessage.OrgnlMndtId == opportunity.Account.UMR__c) {
                        opportunity.Mandate_Activated__c = false;
                        if (lastMessage.EvtTime != null) {
                            opportunity.Mandate_Last_Modified_Date__c = lastMessage.EvtTime;
                        }

                        opportunitiesListToUpdate.add(opportunity);
                    }
                }
            }

            update opportunitiesListToUpdate;
            insert attachmentsToInsertList;
            delete attachmentsToDeleteList;
        }
        catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf(e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
    }


    public void finish(Database.BatchableContext BC) {

    }
}