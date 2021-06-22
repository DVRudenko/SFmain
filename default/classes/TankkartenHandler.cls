public class TankkartenHandler {
    public static Boolean enablesTrigger = true;

    public static void maketouppercase(List<Tankkarten__c> newList) {
    	for (Tankkarten__c t : newList) {
    		if (t.Firmenname_auf_der_Karte__c != null) {
    			t.Firmenname_auf_der_Karte__c = t.Firmenname_auf_der_Karte__c.touppercase();
    		}
    	}
    }
}