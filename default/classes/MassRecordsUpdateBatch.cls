global class MassRecordsUpdateBatch implements Database.Batchable<sObject>{

    private List <sObject> sObjList;
    global MassRecordsUpdateBatch(List <SObject> sObjectsToUpdate){
        sObjList = sObjectsToUpdate;
    }

    global Iterable<sObject> start(Database.BatchableContext context){
        return sObjList;
    }

    global void execute(Database.BatchableContext context, List<Object> scope){
        List <sObject> curSObjList = (List <sObject>) scope;
        update curSObjList;
    }

    global void finish(Database.BatchableContext context){}

}