trigger CreditFactoryReportTrigger on Credit_Factory_Report__c (before insert, after insert, before update, after update, after undelete) {
    if (CreditFactoryReportTriggerHandler.triggerEnabled) {
        new CreditFactoryReportTriggerHandler().run();
    }
}