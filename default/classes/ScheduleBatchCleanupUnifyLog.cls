global class ScheduleBatchCleanupUnifyLog implements Schedulable {

    global void execute(SchedulableContext SC) {
        deleteLogs();
    }

    public static void deleteLogs(){
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Name FROM User]);
        system.debug('Delete log for Users - '+usersMap.size());
        Set<Id> userIds = usersMap.keyset();

        String RecordDateTime = String.valueOf((System.now().addDays(-14)).getTime()) + '_' + ((Math.random() * 1000) + 1000).round();
        String query = 'SELECT Entity_ID__c, RecordDateTime__c FROM Unify_CC_LogStorage__b WHERE Entity_ID__c IN: userIds AND RecordDateTime__c <: RecordDateTime';
        List<Unify_CC_LogStorage__b> scope = Database.query(query);
        System.debug('Records - ' + scope.size());
        Database.deleteImmediate(scope);
    }

}
