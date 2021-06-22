global class ShortLinkOppCleanerBatch implements Database.Batchable<sObject>,Database.Stateful {

    global Map<String,Map<String, Integer>> oppStats = new Map<String,Map<String, Integer>>(); // leadSource -> obn:cnt
    global final Date checkdate = Date.today().addDays(-3);
    global final Date lowerdate = Date.today().addDays(-4);

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT CreatedDate, AccountId, ESI__c,E2E_Last_Activity__c,LeadSource' +
                ' FROM Opportunity WHERE Name LIKE \'LongForm:%\' AND (NOT Name LIKE \'LongForm: %\') AND CreatedDate >: lowerdate AND CreatedDate <: checkdate' +
                ' AND Channel__c = \'POS\' AND LeadSource IN (\'Tablet\',\'QR Code\',\'URL\') AND E2E_Active_Step__c = 0';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> unused_opps) {
        List<Id> accs_to_remove = new List<Id>();
        for (Opportunity opp : unused_opps) {
            String obn = opp.ESI__c;
            if (obn != null && opp.E2E_Last_Activity__c != null){
                String source = (opp.LeadSource == null ? '[NULL]' : opp.LeadSource);
                if(oppStats.containsKey(source)) {
                    Map<String, Integer> sourceMap = oppStats.get(source);
                    if (sourceMap.containsKey(obn))
                        sourceMap.put(obn, sourceMap.get(obn) + 1);
                    else
                        sourceMap.put(obn, 1);
                }
                else{
                    oppStats.put(source,new Map<String,Integer>());
                    Map<String, Integer> sourceMap = oppStats.get(source);
                    sourceMap.put(obn, 1);
                }
            }
            if(opp.E2E_Last_Activity__c == null)
                accs_to_remove.add(opp.AccountId);
        }
        Database.delete(accs_to_remove, false);
        System.debug('removed:' + accs_to_remove.size());
    }

    global void finish(Database.BatchableContext BC) {
        List<ShortLinkEmailNotification__c> settings = ShortLinkEmailNotification__c.getAll().values();

        if(!settings.isEmpty() && !oppStats.isEmpty()) {
            List<String> emails = new List<String>();
            for(ShortLinkEmailNotification__c setting : settings)
                emails.add(setting.Name);

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String subject = 'Tablet Daily Cleaner Report';
            email.setSubject(subject);
            email.setToAddresses(emails);
            email.setHtmlBody(letterTableHTML(oppStats,checkdate.format()));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    email
            });
        }
    }

    private static String letterTableHTML(Map<String,Map<String, Integer>> sourcestats,String createdDate){
        String body = '<html><head><style>table {  font-family: arial, sans-serif;  border-collapse: collapse;  width: 100%;}td, th {  border: 1px solid #dddddd;  text-align: left;  padding: 8px;}tr:nth-child(even) {  background-color: #dddddd;}</style></head><h2>Статистика за $date</h2>'.replace('$date',createdDate);

        for(String source : sourcestats.keySet()){
            body+='<h3>'+source+'</h3><table><tr><th>OBN</th><th>Пользователи,не прошедшие 0 шаг</th></tr>';
            Map<String,Integer> stats = sourcestats.get(source);
            for(String obn : stats.keySet())
                body+='<tr><td>'+obn+'</td><td>'+stats.get(obn)+'</td></tr>';
            body+='</table>';
        }
        body+='</html>';
        return body;

    }

}