@isTest
private class UnprocessedLeadsTest {
    @isTest
    public static void unprocLeads() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Austria',
			CountryCode = 'AT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;

		List<Lead> testLead = [
				SELECT Id 
				FROM Lead 
				WHERE Id = :l.Id
				LIMIT 1];
		system.assertEquals(testlead.size(), 1);
		system.assertEquals(testlead.get(0).Id, l.Id);

		UnprocessedLeads controller = new UnprocessedLeads();
		controller.init();
    }
}