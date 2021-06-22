@IsTest
private class ClickToCallHandlerTest {
    @IsTest
    private static void testSTD1() {
    	List<Lead> leadsToInsertList = new List<Lead>();
		Lead leadDE = new Lead(
			Phone = '+49(0)123123',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadDE);

		Lead leadDE2 = new Lead(
			Phone = '0123123',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadDE2);

		Lead leadDE3 = new Lead(
			Phone = '+375 295077777',
			Country = 'Germany',
			CountryCode = 'DE',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadDE3);

		Lead leadAT = new Lead(
			Phone = '0043123123',
			Country = 'Austria',
			CountryCode = 'AT',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadAT);

		Lead leadPL = new Lead(
			Phone = '48(0)123123',
			Country = 'Poland',
			CountryCode = 'PL',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadPL);

		Lead leadNL = new Lead(
			Phone = '00031123123',
			Country = 'Netherlands',
			CountryCode = 'NL',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadNL);

		Lead leadBE = new Lead(
			Phone = '32123123',
			Country = 'Belgium-FR',
			CountryCode = 'BEFR',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadBE);

		Lead leadFR = new Lead(
			Phone = '33123123',
			Country = 'France',
			CountryCode = 'FR',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadFR);

		Lead leadLU = new Lead(
			Phone = '+352(0)123123',
			Country = 'Luxembourg',
			CountryCode = 'LU',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadLU);

		Lead leadCZ = new Lead(
			Phone = '000420123123',
			Country = 'Czech Republic',
			CountryCode = 'CZ',
			Company = 'test',
			LastName = 'test');
		leadsToInsertList.add(leadCZ);

		insert leadsToInsertList;

		Test.startTest();
			Set<Id> idsToTest = new Set<Id>();
			for (Lead currentLead : leadsToInsertList) {
				idsToTest.add(currentLead.Id);
			}

			Map<Id, Lead> leadsToTestMap = new Map<Id, Lead>([
				SELECT Phone
				FROM Lead
				WHERE Id IN :idsToTest
				LIMIT 10000]);

			// Germany
			System.assertEquals('+49123123', leadsToTestMap.get(leadDE.Id).Phone);
			System.assertEquals('+49123123', leadsToTestMap.get(leadDE2.Id).Phone);
			System.assertEquals('+375295077777', leadsToTestMap.get(leadDE3.Id).Phone);
			// Austria
			System.assertEquals('+43123123', leadsToTestMap.get(leadAT.Id).Phone);
			// Poland
			System.assertEquals('+48123123', leadsToTestMap.get(leadPL.Id).Phone);
			// Netherlands
			System.assertEquals('+31123123', leadsToTestMap.get(leadNL.Id).Phone);
			// Belgium-FR
			System.assertEquals('+32123123', leadsToTestMap.get(leadBE.Id).Phone);
			// France
			System.assertEquals('+33123123', leadsToTestMap.get(leadFR.Id).Phone);
			// Luxembourg
			System.assertEquals('+352123123', leadsToTestMap.get(leadLU.Id).Phone);
			// Czech Republic
			System.assertEquals('+420123123', leadsToTestMap.get(leadCZ.Id).Phone);
		Test.stopTest();
    }
}