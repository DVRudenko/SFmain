public class WeeklyPumpedVolumeController {
    private ApexPages.StandardController controller {get; set;}
    public String currentId {get; set;}
    public Map<Integer, Double> weeklyPumpedVolume {get; set;}
    public Map<Double, Double> delta {get; set;}
    public WeeklyPumpedVolumeController(ApexPages.StandardController controller) {
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
                SELECT Id, client_week_number__c, starts__c, volume__c
                FROM Starts__c 
                WHERE Account__c = :account.Id
                ORDER BY Client_week_number__c
                LIMIT 10];
        weeklyPumpedVolume = new Map<Integer, Double>();
        delta = new Map<Double, Double>();
        for (Starts__c starts : startsList) {
            if (starts.client_week_number__c != null && starts.volume__c != null) {
                weeklyPumpedVolume.put(starts.client_week_number__c.intValue(), starts.volume__c.round(System.RoundingMode.HALF_EVEN));
            }
            if (! opportunityList.isEmpty()) {
                if (opportunityList.get(0).Total_consumption_l_month__c != null) {
                    delta.put(starts.client_week_number__c, (opportunityList.get(0).Total_consumption_l_month__c / 4).round(System.RoundingMode.HALF_EVEN));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR, 'Please add at least one Opportunity in Account.'));
            }
        }
    }
}