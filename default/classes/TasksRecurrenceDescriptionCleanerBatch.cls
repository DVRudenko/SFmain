global with sharing class TasksRecurrenceDescriptionCleanerBatch implements Database.Batchable<sObject> {
    String query;
    Map<String, String> regs = new Map<String, String>{
        'phoneOld' => '((8|\\+7|7)[\\-\\/\\. ]?)?(\\(?\\/?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d)',
        'phone' => '((8|\\+7|7)[\\-\\/\\. ]?)?\\(?(\\d[\\)\\-\\/\\. ]{0,2}){7,10}',
        'emailOld' => '[\\wа-яА-Я\\-\\.\\_ ]+@+([\\wа-яА-Я\\- ]+[\\.\\,]+)+[a-zA-Zа-яА-Я ]{1,4}',
        'email' => '[\\wа-яА-Я\\-\\.\\_ ]+@+([\\wа-яА-Я\\- ]+[\\.\\,]+)+[a-zA-Zа-яА-Я ]{1,4}',
        'inn' => '[\\d]{9,12}'
    };
    Pattern regexPatternPhone;
    Pattern regexPatternEmail;
    Pattern regexPatternInn;
    Date activityDate;

    public TasksRecurrenceDescriptionCleanerBatch() {
        activityDate = Date.today() - 14;
        query = 'SELECT Id, isRecurrence, Description, Status, ActivityDate FROM Task WHERE RecordType.DeveloperName = \'Russian_Sales\' AND isRecurrence = true AND (Status != \'Completed\' OR (Status = \'Completed\' AND ActivityDate < :activityDate))';
        regexPatternPhone = Pattern.compile(regs.get('phone'));
        regexPatternEmail = Pattern.compile(regs.get('email'));
        regexPatternInn = Pattern.compile(regs.get('inn'));
    }

    global void execute(Database.BatchableContext bc, List<Task> scope){
        List<Task> resultList = new List<Task>();
        for (Task currentTask: scope) {
            if (currentTask.Description != null && (regexPatternEmail.matcher(currentTask.Description).find() || regexPatternPhone.matcher(currentTask.Description).find() || regexPatternInn.matcher(currentTask.Description).find())) {
                String emailReplaceResult = regexPatternEmail.matcher(currentTask.Description).replaceAll('X');
                String phoneReplaceResult = regexPatternPhone.matcher(emailReplaceResult).replaceAll('X');
                currentTask.Description = regexPatternInn.matcher(phoneReplaceResult).replaceAll('X');
                resultList.add(currentTask);
            }
        }
        if (resultList.size() > 0) {
            Database.update(resultList, false);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void finish(Database.BatchableContext bc) {}
}