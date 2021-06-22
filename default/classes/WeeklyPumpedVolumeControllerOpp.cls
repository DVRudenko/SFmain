/**
 * Created by Nikita.Mikhailov on 02.03.2018.
 */

public class WeeklyPumpedVolumeControllerOpp {
    private ApexPages.StandardController controller {get; set;}
    public String currentId {get; set;}
    public Map<Integer, Double> weeklyPumpedVolume {get; set;}
    public Map<Double, Double> delta {get; set;}
    public WeeklyPumpedVolumeControllerOpp(ApexPages.StandardController controller) {
        this.controller = controller;
        currentId = ApexPages.currentPage().getParameters().get('id');
        Opportunity opportunity = [
                SELECT Id
                FROM Opportunity
                WHERE Id = :currentId
        ];
        List<Starts__c> startsList = [
                SELECT Id, client_week_number__c, starts__c, volume__c
                FROM Starts__c
                WHERE Opportunity__c = :currentId
                ORDER BY Client_week_number__c
                LIMIT 10];
        weeklyPumpedVolume = new Map<Integer, Double>();
        delta = new Map<Double, Double>();
        for (Starts__c starts : startsList) {
            if (starts.client_week_number__c != null && starts.volume__c != null) {
                weeklyPumpedVolume.put(starts.client_week_number__c.intValue(), starts.volume__c.round(System.RoundingMode.HALF_EVEN));
            }
        }
    }
}