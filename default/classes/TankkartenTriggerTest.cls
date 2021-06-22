@isTest
private class TankkartenTriggerTest {
    @isTest
    public static void testTankkartenName() {
    	Account a = new Account(Name = 'test', BillingCountry = 'Germany');
    	insert a;
		
		Opportunity op = new Opportunity(
				AccountId = a.Id,
				Name = 'test',
				StageName = 'Prospecting',
				CloseDate = Date.today());
		insert op;

    	Tankkarten__c t = new Tankkarten__c(
    		Account__c = a.Id,
			Opportunity__c = op.Id,
    		Firmenname_auf_der_Karte__c = 'test',
            KFZ_Kennzeichen_oder_Fahrername__c = 'test');
    	insert t;

    	t.Firmenname_auf_der_Karte__c = 'test12';
    	update t;

    	Tankkarten__c testCard = [SELECT Firmenname_auf_der_Karte__c FROM Tankkarten__c WHERE Id = :t.Id LIMIT 1];
    	system.assertEquals('TEST12', testCard.Firmenname_auf_der_Karte__c);
    }
}