public with sharing class SparkalkulatorLeadController {
    private ApexPages.StandardController controller {get; set;}
    public Lead lead {get; set;}
    public Integer angebotsdauer {get; set;}
    public Decimal cardPricing {get; set;}

    public SparkalkulatorLeadController(ApexPages.StandardController controller) {
        this.controller = controller;
        this.lead = [
                SELECT Name, Anzahl_der_Fahrzeuge__c, Monatlicher_Kraftstoffverbrauch_in_Liter__c,
                       Angebotsdauer_in_Monate__c, Aktuelle_Zahlungsmethode__c, Company,
                       Zahlungsart__c, Produkt__c
                FROM Lead
                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

        calculatePricing();
    }

    public void calculatePricing() {
        if (lead.Zahlungsart__c != null && lead.Produkt__c != null) {
            if (lead.Zahlungsart__c == 'Lastschrift' && lead.Produkt__c == 'euroShell Card Kompakt') {
                cardPricing = 3.95;
            } else if (lead.Zahlungsart__c == 'Banküberweisung' && lead.Produkt__c == 'euroShell Card Kompakt') {
                cardPricing = 4.95;
            } else if (lead.Zahlungsart__c == 'Lastschrift' && lead.Produkt__c == 'euroShell Card International') {
                cardPricing = 4.95;
            } else if (lead.Zahlungsart__c == 'Banküberweisung' && lead.Produkt__c == 'euroShell Card International') {
                cardPricing = 5.95;
            }
        } else {
            cardPricing = 0;
        }

        if (lead.Angebotsdauer_in_Monate__c != null) {
            angebotsdauer = Integer.valueOf(lead.Angebotsdauer_in_Monate__c);
        }
    }
}