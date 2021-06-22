public with sharing class SparkalkulatorController {
	private ApexPages.StandardController controller {get; set;}
	public Integer angebotsdauer {get; set;}
	public Opportunity opportunity {get; set;}

    public SparkalkulatorController(ApexPages.StandardController controller) {
    	this.controller = controller;
    	this.opportunity = [
    			SELECT Name, Anzahl_der_Karten__c, Kraftstoffverbrauch_Liter_Monat__c, 
    				   Derzeitige_Zahlungsmethode__c, Angebotsdauer__c
    			FROM Opportunity
    			WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

    	if (opportunity.Angebotsdauer__c != null) {
    		if (opportunity.Angebotsdauer__c == '3 Monate') {
    			angebotsdauer = 3;
    		} else if (opportunity.Angebotsdauer__c == '4 Monate') {
    			angebotsdauer = 4;
    		} else if (opportunity.Angebotsdauer__c == '5 Monate') {
    			angebotsdauer = 5;
    		} else if (opportunity.Angebotsdauer__c == '6 Monate') {
    			angebotsdauer = 6;
    		}
    	}
    }
}