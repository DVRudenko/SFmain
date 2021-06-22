/**
 * Created by Nikita.Mikhailov on 02.03.2018.
 */

public class WeeklyNetstartsControllerOpp {
    private ApexPages.StandardController controller { get; set; }
    public String currentId { get; set; }
    public Map<Decimal, Double> weeklyNetstarts { get; set; }
    public WeeklyNetstartsControllerOpp(ApexPages.StandardController controller) {
        this.controller = controller;
        currentId = ApexPages.currentPage().getParameters().get('id');
        Opportunity opportunity = [
                SELECT Id
                FROM Opportunity
                WHERE Id = :currentId
        ];
        List<Starts__c> startsList = [
                SELECT Id, Client_week_number__c, starts__c
                FROM Starts__c
                WHERE Opportunity__c = :currentId
                ORDER BY Client_week_number__c
                LIMIT 10
        ];

        weeklyNetstarts = new Map<Decimal, Double>();
        for (Starts__c starts : startsList) {
            if (starts.starts__c != null) {
                weeklyNetstarts.put(starts.client_week_number__c, starts.starts__c.round(System.RoundingMode.HALF_EVEN));
            } else {
                weeklyNetstarts.put(starts.client_week_number__c, starts.starts__c);
            }
        }
    }
}