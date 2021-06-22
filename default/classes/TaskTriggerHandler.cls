public class TaskTriggerHandler {
    public static Boolean enablesTrigger = true;
    public static Boolean enablesCheckAttachmentExist = true;

    public static Map<String, RecordTypeInfo> taskRecordTypes{
        get{
            if(taskRecordTypes == null){
                taskRecordTypes = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return taskRecordTypes;
        }
        private set;
    }

    public static void updateLastTaskStatusChange(Map<Id, Task> oldMap, Map<Id, Task> newMap) {
        for (Task t : newMap.values()) {
            if (t.Status != oldMap.get(t.Id).Status) {
                t.Last_Task_Status_Change__c = Datetime.now();
            }
        }
    }


    /*******************************************************************************
    *  Name            : sendRecordType(List<Task> newList)
    *  Summary         : set recordType id (BEFORE INSERT)
    *  CreatedDate     : 27/12/2017
    *  ModifiedDate    : 11/01/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void setRecordType(List<Task> newList) {
        Map<String, List<Task>> assignOwnerToTaskMap = new Map<String, List<Task>>();
        for (Task task : newList) {
            if (task.OwnerId != null) {
                if (!assignOwnerToTaskMap.containsKey(task.OwnerId)) {
                    assignOwnerToTaskMap.put(task.OwnerId, new List<Task>());
                }
                assignOwnerToTaskMap.get(task.OwnerId).add(task);
            }
        }

        if (!assignOwnerToTaskMap.isEmpty()) {
            List<User> ownerOfTaskList = [
                    SELECT Id, UserRole.Name
                    FROM User
                    WHERE Id IN :assignOwnerToTaskMap.keySet() AND
                    UserRole.Name LIKE '%PPR%'
                    LIMIT 10000
            ];

            if (!ownerOfTaskList.isEmpty()) {
                for (User usr : ownerOfTaskList) {
                    for (Task task : assignOwnerToTaskMap.get(usr.Id)) {
                        task.RecordTypeId = taskRecordTypes.get('Russian_Sales').getRecordTypeId();
                    }
                }
            }
        }
    }


    /*******************************************************************************
    *  Name            : provideAccessToDeleteTasks(List<Task> oldList)
    *  Summary         : Display error if report has been deleted by Inbound or Outbound Sales Agent
    *  CreatedDate     : 02/08/2017
    *  Parameters      : oldList - old trigger list of Tasks
    *  Returns         : void
    ******************************************************************************/
    public static void provideAccessToDeleteTasks(List<Task> oldList) {
        Map<Id, Profile> profilesMap = new Map<Id, Profile>([
                SELECT Id
                FROM Profile
                WHERE Name = 'Sales Inbound' OR Name = 'Sales'
        ]);

        for (Task task : oldList) {
            if (profilesMap.containsKey(UserInfo.getProfileId())) {
                task.addError('You are not allowed to Delete Task records.');
            }
        }
    }


    /*******************************************************************************
    *  Name            : setPrimaryContact(List<Task> newTasks)
    *  Summary         : Set Contact to the task if task is related to Opportunity. @future call because we
                         can't set WhoId in trigger if shared activities is on and Task was created from the UI
    *  CreatedDate     : 21/12/2017
    *  ModifiedDate    :
    *  Parameters      : newTasks – Trigger.new
    *  Returns         : void
    ******************************************************************************/
    public static void sendToUpdatePrimaryContact(List<Task> newTasks) {
        Set<Id> tasksToUpdateSet = new Set<Id>();
        for (Task task : newTasks) {
            String whatId = task.WhatId;
            if (whatId != null && whatId.substring(0, 3) == '006' && task.WhoId == null) {
                tasksToUpdateSet.add(task.Id);
            }
        }
        if (!tasksToUpdateSet.isEmpty()) {
            setPrimaryContact(tasksToUpdateSet);
        }
    }

    @future
    public static void setPrimaryContact(Set<Id> taskIdsSet) {
        Set<Id> opportunityIdsSet = new Set<Id>();
        List<Task> tasksToUpdate = [
                SELECT WhatId
                FROM Task
                WHERE Id IN :taskIdsSet
                LIMIT 10000
        ];
        for (Task task : tasksToUpdate) {
            opportunityIdsSet.add(task.WhatId);
        }
        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([
                SELECT Id, (SELECT ContactId FROM OpportunityContactRoles WHERE IsPrimary = TRUE)
                FROM Opportunity
                WHERE Id IN :opportunityIdsSet
                LIMIT 10000
        ]);

        List<Task> finalList = new List<Task>();
        for (Task task : tasksToUpdate) {
            if (opportunitiesMap.containsKey(task.WhatId) && !opportunitiesMap.get(task.WhatId).OpportunityContactRoles.isEmpty()) {
                task.WhoId = opportunitiesMap.get(task.WhatId).OpportunityContactRoles.get(0).ContactId;
            }
        }
        update tasksToUpdate;
    }


    /*******************************************************************************
    *  Name            : checkAttachmentExist(List<Task> oldTasks, List<Task> newTasks)
    *  Summary         : update field task.Is_Exist_Attachment__c if exist any attachment in task
    *  CreatedDate     : 14/12/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void checkAttachmentExist(List<Task> newTasks) {
        Set<Id> russianRecordType = new Set<Id>();
        if (Schema.SObjectType.Task.getRecordTypeInfosByName().get('Russian Sales') != null) {
            russianRecordType.add(Schema.SobjectType.Task.getRecordTypeInfosByName().get('Russian Sales').getRecordTypeId());
        } else if (Schema.SObjectType.Task.getRecordTypeInfosByName().get('Российские продажи') != null) {
            russianRecordType.add(Schema.SObjectType.Task.getRecordTypeInfosByName().get('Российские продажи').getRecordTypeId());
        }
        Set<ID> russianTaskIds = new Set<ID>();
        for (Task task : newTasks) {
            if (russianRecordType.contains(task.RecordTypeId)) {
                russianTaskIds.add(task.ID);
            }
        }
        if (russianTaskIds.size() != 0) {
            List<Task> tasksWithAttachment = [
                    SELECT id, Attachments_Exist__c, (SELECT id FROM Attachments)
                    FROM Task
                    WHERE ID IN :russianTaskIds
            ];
            List<Task> taskForUpdate = new List<Task>();
            for (Task task : tasksWithAttachment) {
                if (task.Attachments.size() != 0 && task.Attachments_Exist__c != true) {
                    task.Attachments_Exist__c = true;
                    taskForUpdate.add(task);
                } else if(task.Attachments.size() == 0 && task.Attachments_Exist__c != false) {
                    task.Attachments_Exist__c = false;
                    taskForUpdate.add(task);
                }
            }
            if(taskForUpdate.size() != 0){
                enablesCheckAttachmentExist = false;
                update taskForUpdate;
            }
        }
    }


    /*******************************************************************************
    *  Name            : updateNumberOfOpenTasks(Map<Id, Task> oldMap, Map<Id, Task> newMap)
    *  Summary         : update fields Number_of_open_tasks__c and Open_Task__c for Leads and Opportunities
    *  CreatedDate     : 18/01/2018
    *  ModifiedDate    : 03/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static void updateNumberOfOpenTasksAndCheckbox(Map<Id, Task> oldMap, Map<Id, Task> newMap) {
        Set<Id> leadIdsSet = new Set<Id>();
        Set<Id> opportunityIdsSet = new Set<Id>();

        if (oldMap == null && newMap != null) {
            // after insert and after undelete
            for (Task task : newMap.values()) {
                if (task.IsClosed == false && task.WhoId != null && String.valueOf(task.WhoId).subString(0, 3) == '00Q') {
                    leadIdsSet.add(task.WhoId);
                } else if (task.IsClosed == false && task.WhatId != null && String.valueOf(task.WhatId).substring(0, 3) == '006') {
                    opportunityIdsSet.add(task.WhatId);
                }
            }
        } else if (newMap == null && oldMap != null) {
            // after delete
            for (Task task : oldMap.values()) {
                if (task.IsClosed == false && task.WhoId != null && String.valueOf(task.WhoId).subString(0, 3) == '00Q') {
                    leadIdsSet.add(task.WhoId);
                } else if (task.IsClosed == false && task.WhatId != null && String.valueOf(task.WhatId).subString(0, 3) == '006') {
                    opportunityIdsSet.add(task.WhatId);
                }
            }
        } else if (newMap != null && oldMap != null) {
            // after update
            for (Task task : newMap.values()) {
                if ((task.isClosed != oldMap.get(task.Id).isClosed || task.WhoId != oldMap.get(task.Id).WhoId) && task.WhoId != null && String.valueOf(task.WhoId).subString(0, 3) == '00Q') {
                    leadIdsSet.add(task.WhoId);
                } else if ((task.isClosed != oldMap.get(task.Id).isClosed || task.WhatId != oldMap.get(task.Id).WhatId) && task.WhatId != null && String.valueOf(task.WhatId).subString(0, 3) == '006') {
                    opportunityIdsSet.add(task.WhatId);
                } else if (task.isClosed == false && task.OwnerId != oldMap.get(task.id).OwnerId) {
                    if (task.WhoId != null && String.valueOf(task.WhoId).subString(0, 3) == '00Q') {
                        leadIdsSet.add(task.WhoId);
                    } else if (task.WhatId != null && String.valueOf(task.WhatId).subString(0, 3) == '006') {
                        opportunityIdsSet.add(task.WhatId);
                    }
                }
            }
        }

        // lead
        if (!leadIdsSet.isEmpty()) {
            List<Lead> leadsToUpdate = [
                    SELECT Id, Number_of_open_tasks__c, Open_Task__c, OwnerId, (SELECT Id, OwnerId FROM Tasks WHERE IsClosed = false)
                    FROM Lead
                    WHERE Id IN :leadIdsSet
                    LIMIT 50000
            ];

            List<Lead> finalLeadsToUpdateList = new List<Lead>();
            Boolean lastState;
            for (Lead lead : leadsToUpdate) {
                lastState = lead.Open_Task__c;
                lead.Open_Task__c = false;

                for (Task task : lead.Tasks) {
                    if (lead.OwnerId.equals(task.OwnerId)) {
                        lead.Open_Task__c = true;
                        break;
                    }
                }

                if (lead.Number_of_open_tasks__c != lead.Tasks.size() || lead.Open_Task__c != lastState) {
                    lead.Number_of_open_tasks__c = lead.Tasks.size();
                    finalLeadsToUpdateList.add(lead);
                }
            }
            update finalLeadsToUpdateList;
        }
        // opportunity
        if (!opportunityIdsSet.isEmpty()) {
            List<Opportunity> opptyToUpdate = [
                    SELECT Id, Number_of_open_tasks__c, Open_Task__c, OwnerId, (SELECT Id, OwnerId FROM Tasks WHERE IsClosed = false)
                    FROM Opportunity
                    WHERE Id IN :opportunityIdsSet
                    LIMIT 50000
            ];

            List<Opportunity> finalOpptiesToUpdateList = new List<Opportunity>();
            Boolean lastState;
            for (Opportunity oppty : opptyToUpdate) {
                lastState = oppty.Open_Task__c;
                oppty.Open_Task__c = false;

                for (Task task : oppty.Tasks) {
                    if (oppty.OwnerId.equals(task.OwnerId)) {
                        oppty.Open_Task__c = true;
                        break;
                    }
                }

                if (oppty.Number_of_open_tasks__c != oppty.Tasks.size() || oppty.Open_Task__c != lastState) {
                    oppty.Number_of_open_tasks__c = oppty.Tasks.size();
                    finalOpptiesToUpdateList.add(oppty);
                }
            }
            update finalOpptiesToUpdateList;
        }
    }


    /*******************************************************************************
    *  Name            : setFive9Phone(Map<Id, Task> oldMap, List<Task> newList)
    *  Summary         : Set Phone in E.164 format
    *  CreatedDate     : 30/03/2018
    *  ModifiedDate    : 30/03/2018
    *  Parameters      : oldMap, newList – maps from the trigger
    *  Returns         : void
    ******************************************************************************/
    public static void setValidPhone(Map<Id, Task> oldMap, List<Task> newList) {
        Set<Id> leadIdsSet = new Set<Id>();
        Set<Id> contactIdsSet = new Set<Id>();
        Set<Id> opportunityIdsSet = new Set<Id>();
        Set<Id> accountIdsSet = new Set<Id>();

        for (Task task : newList) {
            if (task.WhoId != null && String.valueOf(task.WhoId).substring(0, 3) == '00Q') {
                leadIdsSet.add(task.WhoId);
            } else if (task.WhoId != null && String.valueOf(task.WhoId).substring(0, 3) == '003') {
                contactIdsSet.add(task.WhoId);
            }

            if (task.WhoId == null && task.WhatId != null && String.valueOf(task.WhatId).substring(0, 3) == '006') {
                opportunityIdsSet.add(task.WhatId);
            } else if (task.WhoId == null && task.WhatId != null && String.valueOf(task.WhatId).substring(0, 3) == '001') {
                accountIdsSet.add(task.WhatId);
            }
        }

        // Task with Lead
        if (!leadIdsSet.isEmpty()) {
            Map<Id, Lead> idToLeadMap = new Map<Id, Lead>([
                    SELECT CountryCode
                    FROM Lead
                    WHERE Id IN :leadIdsSet AND
                    CountryCode != null
                    LIMIT 50000
            ]);

            if (!idToLeadMap.isEmpty()) {
                for (Task task : newList) {
                    if (OldMap != null && idToLeadMap.containsKey(task.WhoId)) {
                        // before update
                        if (task.NVMContactWorld__ContactWorld_Number__c != null && oldMap.get(task.Id).NVMContactWorld__ContactWorld_Number__c != task.NVMContactWorld__ContactWorld_Number__c) {
                            task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToLeadMap.get(task.WhoId).CountryCode);
                        }
                        if (task.NVMContactWorld__Customer_Number__c != null && oldMap.get(task.Id).NVMContactWorld__Customer_Number__c != task.NVMContactWorld__Customer_Number__c) {
                            task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToLeadMap.get(task.WhoId).CountryCode);
                        }
                    }
                    if (OldMap == null && idToLeadMap.containsKey(task.WhoId)) {
                        // before insert
                        if (task.NVMContactWorld__ContactWorld_Number__c != null) {
                            task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToLeadMap.get(task.WhoId).CountryCode);
                        }
                        if (task.NVMContactWorld__Customer_Number__c != null) {
                            task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToLeadMap.get(task.WhoId).CountryCode);
                        }
                    }
                }
            }
        }

        // Task with Contact
        if (!contactIdsSet.isEmpty()) {
            Map<Id, Contact> idToContactMap = new Map<Id, Contact>([
                    SELECT MailingCountryCode
                    FROM Contact
                    WHERE Id IN :contactIdsSet AND
                    MailingCountryCode != null
                    LIMIT 50000
            ]);

            if (!idToContactMap.isEmpty()) {
                for (Task task : newList) {
                    if (OldMap != null && idToContactMap.containsKey(task.WhoId)) {
                        // before update
                        if (task.NVMContactWorld__ContactWorld_Number__c != null && oldMap.get(task.Id).NVMContactWorld__ContactWorld_Number__c != task.NVMContactWorld__ContactWorld_Number__c) {
                            task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToContactMap.get(task.WhoId).MailingCountryCode);
                        }
                        if (task.NVMContactWorld__Customer_Number__c != null && oldMap.get(task.Id).NVMContactWorld__Customer_Number__c != task.NVMContactWorld__Customer_Number__c) {
                            task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToContactMap.get(task.WhoId).MailingCountryCode);
                        }
                    }
                    if (OldMap == null && idToContactMap.containsKey(task.WhoId)) {
                        // before insert
                        if (task.NVMContactWorld__ContactWorld_Number__c != null) {
                            task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToContactMap.get(task.WhoId).MailingCountryCode);
                        }
                        if (task.NVMContactWorld__Customer_Number__c != null) {
                            task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToContactMap.get(task.WhoId).MailingCountryCode);
                        }
                    }
                }
            }
        }

        // Task with Opportunity
        if (!opportunityIdsSet.isEmpty()) {
            Map<Id, Opportunity> idToOpptyMap = new Map<Id, Opportunity>([
                    SELECT Account.BillingCountryCode
                    FROM Opportunity
                    WHERE Id IN :opportunityIdsSet AND
                    Account.BillingCountryCode != null
                    LIMIT 50000
            ]);

            if (!idToOpptyMap.isEmpty()) {
                for (Task task : newList) {
                    if (OldMap != null && idToOpptyMap.containsKey(task.WhatId)) {
                        // before update
                        if (task.NVMContactWorld__ContactWorld_Number__c != null && oldMap.get(task.Id).NVMContactWorld__ContactWorld_Number__c != task.NVMContactWorld__ContactWorld_Number__c) {
                            task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToOpptyMap.get(task.WhatId).Account.BillingCountryCode);
                        }
                        if (task.NVMContactWorld__Customer_Number__c != null && oldMap.get(task.Id).NVMContactWorld__Customer_Number__c != task.NVMContactWorld__Customer_Number__c) {
                            task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToOpptyMap.get(task.WhatId).Account.BillingCountryCode);
                        }
                    }
                    if (OldMap == null && idToOpptyMap.containsKey(task.WhatId)) {
                        // before insert
                        if (task.NVMContactWorld__ContactWorld_Number__c != null) {
                            task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToOpptyMap.get(task.WhatId).Account.BillingCountryCode);
                        }
                        if (task.NVMContactWorld__Customer_Number__c != null) {
                            task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToOpptyMap.get(task.WhatId).Account.BillingCountryCode);
                        }
                    }
                }
            }
        }

        // Task with Account
        if (!accountIdsSet.isEmpty()) {
            Map<Id, Account> idToAccountMap = new Map<Id, Account>([
                    SELECT BillingCountryCode
                    FROM Account
                    WHERE Id IN :accountIdsSet AND
                    BillingCountryCode != null
                    LIMIT 50000
            ]);

            if (!idToAccountMap.isEmpty()) {
                for (Task task : newList) {
                    if (OldMap != null && idToAccountMap.containsKey(task.WhatId)) {
                        // before update
                        if (task.NVMContactWorld__ContactWorld_Number__c != null && oldMap.get(task.Id).NVMContactWorld__ContactWorld_Number__c != task.NVMContactWorld__ContactWorld_Number__c) {
                            task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToAccountMap.get(task.WhatId).BillingCountryCode);
                        }
                        if (task.NVMContactWorld__Customer_Number__c != null && oldMap.get(task.Id).NVMContactWorld__Customer_Number__c != task.NVMContactWorld__Customer_Number__c) {
                            task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToAccountMap.get(task.WhatId).BillingCountryCode);
                        }
                    }
                    if (OldMap == null && idToAccountMap.containsKey(task.WhatId)) {
                        // before insert
                        if (task.NVMContactWorld__ContactWorld_Number__c != null) {
                            task.NVMContactWorld__ContactWorld_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__ContactWorld_Number__c, idToAccountMap.get(task.WhatId).BillingCountryCode);
                        }
                        if (task.NVMContactWorld__Customer_Number__c != null) {
                            task.NVMContactWorld__Customer_Number__c = ClickToCallHandler.returnValidNumber(task.NVMContactWorld__Customer_Number__c, idToAccountMap.get(task.WhatId).BillingCountryCode);
                        }
                    }
                }
            }
        }
    }




    /*******************************************************************************
    *  Name            : setTodayDueDay(List<Task> newTaskList)
    *  Summary         : set today in due date field if checkbox Due_Date_Today__c is checked
    *  CreatedDate     : 26/11/2020 by Anton Hrytsavets
    *  Returns         : void
    ******************************************************************************/
    public static void setTodayDueDay(List<Task> newTaskList) {
        for(Task newTask : newTaskList) {
            if(newTask.Due_Date_Today__c) {
                newTask.ActivityDate = Date.today();
            }
        }
    }
}