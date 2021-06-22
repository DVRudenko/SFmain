public with sharing class TaskController {

    @AuraEnabled
    public static Id createRelatedCase(Id taskId){
        Task currentTask = [
            SELECT  Id, 
                    Account__c, 
                    Phone__c,
                    Topic__c,
                    Sub_topic__c,
                    WhoId
            FROM    Task
            WHERE   Id =: taskId
        ];
        if(String.isEmpty(currentTask.Topic__c) || String.isEmpty(currentTask.Sub_topic__c)){
            throw new AuraHandledException('Please populate Topic and Sub topic fields');
        }
        RecordType callTaskType = [
            SELECT  Id
            FROM    RecordType
            WHERE   Name = 'Support'
        ];
        Case relatedCase = new Case(
            RecordTypeId = callTaskType.Id,
            AccountId = currentTask.Account__c,
            Phone_Number__c =currentTask.Phone__c,
            Topic__c = currentTask.Topic__c,
            Sub_topic__c = currentTask.Sub_topic__c,
            ContactId = currentTask.WhoId,
            Status ='New'
        );
        insert relatedCase;
        currentTask.WhatId = relatedCase.Id;
        update currentTask;
        return relatedCase.Id;
    }
}