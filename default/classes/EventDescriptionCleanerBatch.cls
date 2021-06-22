global class EventDescriptionCleanerBatch  implements Database.Batchable<sObject> {
    String query;
    Map<String, String> regs = new Map<String, String>{
        'phoneOld' => '((8|\\+7|7)[\\-\\/\\. ]?)?(\\(?\\/?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d\\)?[\\-\\/\\. ]?\\d)',
        'phone' => '((8|\\+7|7)[\\-\\/\\. ]?)?\\(?(\\d[\\)\\-\\/\\. ]{0,2}){7,10}',
        'emailOld' => '[\\wа-яА-Я\\-\\.\\_ ]+@+([\\wа-яА-Я\\- ]+[\\.\\,]+)+[a-zA-Zа-яА-Я ]{1,4}',
        'email' => '[a-zA-Z0-9а-яА-Я\\-\\.\\_ ]+@{1,2}[a-zA-Z0-9а-яА-Я\\-\\.\\, ]+([a-zA-Zа-яА-Я ]{1,4})+',
        'inn' => '[\\d]{9,12}'
    };
    Pattern regexPatternPhone;
    Pattern regexPatternEmail;
    Pattern regexPatternInn;
    Datetime startDateTime;

    public EventDescriptionCleanerBatch() {
        startDateTime = Datetime.now() - 14;
        query = 'SELECT Id, Description, Event_Status__c, StartDateTime FROM Event WHERE ' + 
            'RecordType.developername = \'Russian_Sales_Event\' AND ' + 
            '(Event_Status__c != \'Completed\' OR (Event_Status__c = \'Completed\' AND StartDateTime < :startDateTime)) ALL ROWS';
        regexPatternPhone = Pattern.compile(regs.get('phone'));
        regexPatternEmail = Pattern.compile(regs.get('email'));
        regexPatternInn = Pattern.compile(regs.get('inn'));
    }

    global void execute(Database.BatchableContext bc, List<Event> scope){
        List<Event> resultList = new List<Event>();
        for (Event currentEvent: scope) {
            if (currentEvent.Description != null && (regexPatternEmail.matcher(currentEvent.Description).find() || regexPatternPhone.matcher(currentEvent.Description).find() || regexPatternInn.matcher(currentEvent.Description).find())) {
                String emailReplaceResult = regexPatternEmail.matcher(currentEvent.Description).replaceAll('X');
                String phoneReplaceResult = regexPatternPhone.matcher(emailReplaceResult).replaceAll('X');
                currentEvent.Description = regexPatternInn.matcher(phoneReplaceResult).replaceAll('X');
                resultList.add(currentEvent);
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