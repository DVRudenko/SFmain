global class BatchCheckingStartsStatus implements Database.Batchable<sObject> {
    public String query;
    public Map<String, BackOffice_Notifications__c> backOfficeNotifyCustomSettingMap;

    global BatchCheckingStartsStatus() {
        this.query = 'SELECT OwnerId, Starts_Status__c, Starts_Rep__c, Starts_Status_Delay__c, Account.BillingCountry, Starts_Schedule__c ' + 
                     'FROM Opportunity ' +
                     'WHERE (RecordType.Name = \'Euroshell Starts\' OR ' + 
                            '(RecordType.Name = \'Euroshell\' AND Starts_Status__c = \'0. Request received\') OR ' +
                            '(RecordType.Name = \'Euroshell\' AND Starts_Status__c = \'0.5 Missing information\') OR ' + 
                            '(RecordType.Name = \'Euroshell\' AND Starts_Status__c = \'1. Customer registered in GFN (card issued & delivered)\')) AND ' +
                            'StageName = \'Closed Won\' AND ' +
                            'Starts_Status_Delay__c = false AND ' +
                            'Starts_Status__c IN :allStartsStatusesSet';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        List<Opportunity> opptyToBackOfficeList = new List<Opportunity>();
        List<Opportunity> opptyToOwnerList = new List<Opportunity>();
        List<Opportunity> opptyToStartsRepList = new List<Opportunity>();
        Map<String, Opportunity> allOpportunitiesMap = new Map<String, Opportunity>();
        for (Sobject so : scope) {
            Opportunity opp = (Opportunity) so;      
            if (statusesForEmailToBackOfficeSet.contains(opp.Starts_Status__c) && opp.Starts_Schedule__c < Date.today()) {
                opptyToBackOfficeList.add(opp);
            } else if (statusesForEmailToOppOwnerSet.contains(opp.Starts_Status__c) && opp.Starts_Schedule__c < Date.today()) {
                opptyToOwnerList.add(opp);
            } else if (statusesForEmailToStartsRepSet.contains(opp.Starts_Status__c) && opp.Starts_Schedule__c < Date.today()) {
                opptyToStartsRepList.add(opp);
            }
            allOpportunitiesMap.put(opp.Id, opp); 
        }
        sendEmail(opptyToBackOfficeList, opptyToOwnerList, opptyToStartsRepList, allOpportunitiesMap);
    }

    global void finish(Database.BatchableContext BC) {
    }


    public void sendEmail(List<Opportunity> opptyToBackOfficeList,
                          List<Opportunity> opptyToOwnerList, 
                          List<Opportunity> opptyToStartsRepList,
                          Map<String, Opportunity> allOpportunitiesMap) {

        List<Messaging.SingleEmailMessage> finalAllmsgList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> allmsgToBackOffice = new List<Messaging.SingleEmailMessage>();
        Map<String, Messaging.SingleEmailMessage> oppIdToMailBackOfficeMap = new Map<String, Messaging.SingleEmailMessage>();

        if (! opptyToBackOfficeList.isEmpty()) {
            EmailTemplate emailTemplate = [
                SELECT Id, Subject, HtmlValue, Body
                FROM EmailTemplate 
                WHERE DeveloperName = 'SLA_Overdue_to_BackOffice'
                LIMIT 1];
      
            for (Opportunity oppty :opptyToBackOfficeList) {
                    Messaging.SingleEmailMessage mailToBOtemp = new Messaging.SingleEmailMessage();
                    mailToBOtemp.setTemplateID(emailTemplate.Id); 
                    mailToBOtemp.setTargetObjectId(oppty.OwnerId); 
                    mailToBOtemp.setSaveAsActivity(false);
                    mailToBOtemp.setWhatId(oppty.Id);
                    mailToBOtemp.setCharset('UTF-8');
                    allmsgToBackOffice.add(mailToBOtemp);
                    oppIdToMailBackOfficeMap.put(oppty.Id, mailToBOtemp);
                oppty.Starts_Status_Delay__c = true;
            } 
        }

        if (! opptyToOwnerList.isEmpty() ) {
            EmailTemplate emailTemplate = [
                SELECT Id, Subject, HtmlValue, Body
                FROM EmailTemplate 
                WHERE DeveloperName = 'SLA_Overdue_to_OpptyOwner'
                LIMIT 1];
            for (Opportunity opp :opptyToOwnerList) {
                Messaging.SingleEmailMessage mailToOwner = new Messaging.SingleEmailMessage();
                mailToOwner.setTemplateID(emailTemplate.Id); 
                mailToOwner.setTargetObjectId(opp.OwnerId); 
                mailToOwner.setSaveAsActivity(false);
                mailToOwner.setWhatId(opp.Id);
                finalAllmsgList.add(mailToOwner);
                opp.Starts_Status_Delay__c = true;
            }

        }

        if (! opptyToStartsRepList.isEmpty() ) {
            EmailTemplate emailTemplate = [
                SELECT Id, Subject, HtmlValue, Body
                FROM EmailTemplate 
                WHERE DeveloperName = 'SLA_Overdue_to_StartsRep'
                LIMIT 1];
            for (Opportunity opportunity :opptyToStartsRepList) {
                Messaging.SingleEmailMessage maiToStartsRep = new Messaging.SingleEmailMessage();
                maiToStartsRep.setTemplateID(emailTemplate.Id); 
                maiToStartsRep.setTargetObjectId(opportunity.Starts_Rep__c); 
                maiToStartsRep.setSaveAsActivity(false);
                maiToStartsRep.setWhatId(opportunity.Id);
                finalAllmsgList.add(maiToStartsRep);
                opportunity.Starts_Status_Delay__c = true;
            }
        }

        //emails list for BackOffice
        if (! allmsgToBackOffice.isEmpty()) {
            Savepoint sp = Database.setSavepoint();
            if ( ! Test.isRunningTest()) {
                Messaging.sendEmail(allmsgToBackOffice);
                Database.rollback(sp);
            }

            String emailText;
            String emailSubject;
            backOfficeNotifyCustomSettingMap = BackOffice_Notifications__c.getAll();
            List<String> emailAddressesList = new List<String>();
            if (! oppIdToMailBackOfficeMap.isEmpty()) {           
                for (String oppId : oppIdToMailBackOfficeMap.keySet()) {
                    if (allOpportunitiesMap.get(oppId).Account.BillingCountry != null &&
                        backOfficeNotifyCustomSettingMap.get(allOpportunitiesMap.get(oppId).Account.BillingCountry).Active__c == true) {
                            emailText = oppIdToMailBackOfficeMap.get(oppId).getHtmlBody();
                            emailSubject = oppIdToMailBackOfficeMap.get(oppId).getSubject();
                            emailAddressesList.clear();
                            emailAddressesList.add(backOfficeNotifyCustomSettingMap.get(allOpportunitiesMap.get(oppId).Account.BillingCountry).Email__c);
                            Messaging.SingleEmailMessage mailToBackOffice = new Messaging.SingleEmailMessage();
                            mailToBackOffice.setSubject(emailSubject);
                            mailToBackOffice.setHtmlBody(emailText);   
                            mailToBackOffice.setToAddresses(emailAddressesList);
                            mailToBackOffice.setSaveAsActivity(false);
                            mailToBackOffice.setCharset('UTF8');
                            finalAllmsgList.add(mailToBackOffice);
                    }
                }       
            }
        }
        //final sending
        if (! Test.isRunningTest()) {
            Messaging.sendEmail(finalAllmsgList, false);     
        }
        update opptyToBackOfficeList;
        update opptyToOwnerList;
        update opptyToStartsRepList;
    }


    private Set<String> allStartsStatusesSet = new Set<String>{
        '0. Request received',
        '0.4 Registration in GFN: Winback',
        '0.5 Missing information',
        '0.6 Missing information provided',
        '0.9 Ready for GFN',
        '1. Customer registered in GFN (card issued & delivered)',
        '2.1 First Check: Cards/PIN s Received',
        '2.2 First Check: Not Reached',
        '2.3 First Check: Delay',
        '2.4 First Check: Winback',
        '3.1 Volume Check 1: Customer Pumping',
        '3.2 Volume Check 1: Not Reached',
        '3.3 Volume Check 1: Delay',
        '3.4 Volume Check 1: Winback',
        '4.1.1 Volume Check 2: Pumping Enough',
        '4.1.2 Volume Check 2: Pumping NOT Enough',
        '4.2 Volume Check 2: Not Reached',
        '4.3 Volume Check 2: Delay',
        '4.4 Volume Check 2: Winback',
        '5.4 Final Check: Winback'
    };

    private Set<String> statusesForEmailToBackOfficeSet = new Set<String>{
        '0. Request received',
        '0.6 Missing information provided',
        '0.9 Ready for GFN'
    };

    private Set<String> statusesForEmailToOppOwnerSet = new Set<String>{
        '0.4 Registration in GFN: Winback',
        '0.5 Missing information',
        '1. Customer registered in GFN (card issued & delivered)',
        '2.4 First Check: Winback',
        '3.4 Volume Check 1: Winback',
        '4.4 Volume Check 2: Winback',
        '5.4 Final Check: Winback'
    };

    private Set<String> statusesForEmailToStartsRepSet = new Set<String>{
        '2.1 First Check: Cards/PIN s Received',
        '2.2 First Check: Not Reached',
        '2.3 First Check: Delay',
        '3.1 Volume Check 1: Customer Pumping',
        '3.2 Volume Check 1: Not Reached',
        '3.3 Volume Check 1: Delay',
        '4.1.1 Volume Check 2: Pumping Enough',
        '4.1.2 Volume Check 2: Pumping NOT Enough',
        '4.2 Volume Check 2: Not Reached',
        '4.3 Volume Check 2: Delay'
    };
}