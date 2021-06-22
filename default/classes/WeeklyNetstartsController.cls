public class WeeklyNetstartsController {
    private ApexPages.StandardController controller {get; set;}
    public String currentId {get; set;}
    public Map<Decimal, Double> weeklyNetstarts {get; set;}
    public WeeklyNetstartsController(ApexPages.StandardController controller) {
        this.controller = controller;
        currentId = ApexPages.currentPage().getParameters().get('id');
        Account account = [
                SELECT Id, (SELECT Id FROM Starts__r)
                FROM Account 
                WHERE Id = :currentId];
        List<Opportunity> opportunityList = [
                SELECT Id, Total_consumption_l_month__c
                FROM Opportunity 
                WHERE AccountId = :account.Id
                LIMIT 1];
        List<Starts__c> startsList = [
                SELECT Id, Client_week_number__c, starts__c
                FROM Starts__c 
                WHERE Account__c = :account.Id
                ORDER BY Client_week_number__c
                LIMIT 10];
        Map<Decimal, Double> weeklyStarts = new Map<Decimal, Double>();
        for (Starts__c starts : startsList) {
            if (starts.starts__c != null) {
                weeklyStarts.put(starts.client_week_number__c, starts.starts__c.round(System.RoundingMode.HALF_EVEN)); 
            } else {
                weeklyStarts.put(starts.client_week_number__c, starts.starts__c);
            }        
        }

        weeklyNetstarts = new Map<Decimal, Double>();
        for (Starts__c starts : startsList) {
            if (starts.client_week_number__c != null && weeklyStarts.get(starts.client_week_number__c) != null) {
                if (weeklyStarts.get(starts.client_week_number__c - 1) != null) {
                    weeklyNetstarts.put(starts.client_week_number__c, weeklyStarts.get(starts.client_week_number__c) - weeklyStarts.get(starts.client_week_number__c - 1));
                } else {
                    weeklyNetstarts.put(starts.client_week_number__c, weeklyStarts.get(starts.client_week_number__c));
                }
            }
        }
    }
}