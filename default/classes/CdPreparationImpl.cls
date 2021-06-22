public with sharing class CdPreparationImpl implements CdPreparationInterface{

    public void before(){
        LeadHandler.context = LeadHandler.TriggerContext.DISTRIBUTION_ENGINE.name();
        OpportunityTriggerHandler.context = OpportunityTriggerHandler.TriggerContext.DISTRIBUTION_ENGINE.name();
    }

    public void after(){}

}