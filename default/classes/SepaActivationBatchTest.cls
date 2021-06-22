@IsTest
public class SepaActivationBatchTest {


	/*******************************************************************************
    *  Summary         : create test data for all methods
    *  Created         : 06/10/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
	@TestSetup
	static void createDataForAllTests() {
		Twikey__c twikeySettings = new Twikey__c(
			Name = 'Test',
			Active__c = true,
			Token__c = '4AF3EAB7D47D13C9CF708C73AB4F9129C224E78B',
			Endpoint__c = 'https://api.beta.twikey.com',
			B2B_Template_Id__c = '1896',
			Core_Template_Id__c = '1897');

		insert twikeySettings;
	}


	/*******************************************************************************
	*  Summary         : test update feed request (Activated)
	*  CreatedDate     : 05/10/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    @isTest
	static void testUpdateFeedRequestActivated() {
		Account account = new Account(
			Name = 'Test Account',
			BillingCountry = 'Belgium-NL'
		);

		insert account;

		account = [
				SELECT UMR__c
				FROM Account
				WHERE Id = :account.Id
		];

		Opportunity opportunity = new Opportunity(
            Name = 'Test opportunity',
            AccountId = account.Id,
            StageName = 'Prospecting',
            Send_SEPA_approval_link__c = true,
			SEPA_Request_Approved__c = false,
            CloseDate = Date.today(),
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
			IBAN__c = 'BE71096123456769',
			SWIFT_BIC__c = 'GKCCBEBB'
        );

		insert opportunity;

		opportunity = [
				SELECT Account.UMR__c, StageName, Mandate_Last_Modified_Date__c, Mandate_Activated__c
				FROM Opportunity
				WHERE Id = :opportunity.Id
		];

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock loginMock = new SingleRequestMock(200, 'Complete', '{"Authorization": "d78bb8a4-483e-4140-8967-748ca8794020"}', new Map<String, String> {'Authorization' => '47de7c97-da18-42dc-a8bd-3864410cd02a'});
            mocksMap.put('https://api.beta.twikey.com/creditor', loginMock);
			SingleRequestMock pdfMock = new SingleRequestMock(200, 'Complete', 'test pdf', null);
            mocksMap.put('https://api.beta.twikey.com/creditor/mandate/pdf?mndtId=' + account.UMR__c, pdfMock);
			HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			Twikey__c twikeySettings = Twikey__c.getInstance('Test');
			TwikeyEntity twikeyEntity = TwikeyEntity.parse('{"GrpHdr": {"CreDtTm": "2020-11-04T16:30:44Z"},"Messages": [{"Mndt": {"MndtId": "' + account.UMR__c + '","LclInstrm": "CORE","Ocrncs": {"SeqTp": "RCUR","Frqcy": "ADHO","Drtn": {"FrDt": "2020-11-05"}},"CdtrSchmeId": "DE17ZZZ00001536434","Cdtr": {"Nm": "FleetCor Belgium BVBA","PstlAdr": {"AdrLine": "Havenlaan 86C bus 204","PstCd": "1000","TwnNm": "Brussel","Ctry": "BE"},"Id": "BE0505807092","CtryOfRes": "BE","CtctDtls": {"EmailAdr": "petr.cermak@fleetcor.eu"}},"Dbtr": {"Nm": "AGNES TESTELMANS","PstlAdr": {"AdrLine": "Test address","PstCd": "1123","TwnNm": "Brugge","Ctry": "BE"},"CtryOfRes": "BE","CtctDtls": {"EmailAdr": "anton.buzak@enway.com"}},"DbtrAcct": "BE68539007547034","DbtrAgt": {"FinInstnId": {"BICFI": "GKCCBEBB","Nm": "BELFIUS BANK"}},"RfrdDoc": "Conditions générales","SplmtryData": [{"Key": "TRACKER","Value": "apM3"},{"Key": "SignerMethod#0","Value": "mock"},{"Key": "Signer#0","Value": "Twikey Mock Signer"},{"Key": "SignerPlace#0","Value": "Minsk"},{"Key": "SignerDate#0","Value": "2020-11-05T12:12:08Z"},{"Key": "FirstName","Value": "AGNES"},{"Key": "LastName","Value": "TESTELMANS"},{"Key": "Language","Value": "fr"},{"Key": "MandateName","Value": "SEPA CORE domiciliation pour Fleetcor BE - Test"},{"Key": "TemplateId","Value": 1897}]},"EvtTime": "2020-11-05T12:12:46Z"}]}');
            SepaActivationBatch batch = new SepaActivationBatch(twikeySettings, twikeyEntity);
			Database.BatchableContext bc;
            batch.start(bc);
            batch.execute(bc, new List<Opportunity> {opportunity});
            batch.finish(bc);
		Test.stopTest();

		Opportunity testOpportunity = [
				SELECT Mandate_Activated__c, Mandate_Last_Modified_Date__c
				FROM Opportunity
				WHERE Id = :opportunity.Id
				LIMIT 1
		];

		System.assertEquals(true, testOpportunity.Mandate_Activated__c);
		System.assertEquals('2020-11-05T12:12:46Z', testOpportunity.Mandate_Last_Modified_Date__c);

		Attachment testAttachment = [
				SELECT Name
				FROM Attachment
				LIMIT 1
		];

		System.assertEquals('SEPAMandate', testAttachment.Name);
    }


    /*******************************************************************************
	*  Summary         : test update feed request (Cancelled)
	*  CreatedDate     : 05/10/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    @isTest
	static void testUpdateFeedRequestCancelled() {
		Account account = new Account(
			Name = 'Test Account',
			BillingCountry = 'Belgium-NL'
		);

		insert account;

		account = [
				SELECT UMR__c
				FROM Account
				WHERE Id = :account.Id
		];

		Opportunity opportunity = new Opportunity(
            Name = 'Test opportunity',
            AccountId = account.Id,
            StageName = 'Prospecting',
            Send_SEPA_approval_link__c = true,
			SEPA_Request_Approved__c = false,
            CloseDate = Date.today(),
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'Core',
			IBAN__c = 'DE30160400000577000300',
			SWIFT_BIC__c = '7654321',
			Mandate_Activated__c = true
        );

		insert opportunity;

		opportunity = [
				SELECT Account.UMR__c, StageName, Mandate_Last_Modified_Date__c, Mandate_Activated__c
				FROM Opportunity
				WHERE Id = :opportunity.Id
		];

        Test.startTest();
            SingleRequestMock loginMock = new SingleRequestMock(200, 'Complete', '{"Authorization": "d78bb8a4-483e-4140-8967-748ca8794020"}', new Map<String, String> {'Authorization' => '47de7c97-da18-42dc-a8bd-3864410cd02a'});
			Test.setMock(HttpCalloutMock.class, loginMock);
			Twikey__c twikeySettings = Twikey__c.getInstance('Test');
			TwikeyEntity twikeyEntity = TwikeyEntity.parse('{"GrpHdr": {"CreDtTm": "2020-11-06T13:40:03Z"},"Messages": [{"CxlRsn": {"Orgtr": {"Nm": "FleetCor Belgium BVBA","PstlAdr": {"AdrLine": "Havenlaan 86C bus 204","PstCd": "1000","TwnNm": "Brussel","Ctry": "BE"},"Id": "BE0505807092","CtryOfRes": "BE","CtctDtls": {"EmailAdr": "petr.cermak@fleetcor.eu"}},"Rsn": "test"},"OrgnlMndtId": "' + account.UMR__c + '","CdtrSchmeId": "DE17ZZZ00001536434","EvtTime": "2020-11-06T13:26:29Z"}]}');
            SepaActivationBatch batch = new SepaActivationBatch(twikeySettings, twikeyEntity);
			Database.BatchableContext bc;
            batch.start(bc);
            batch.execute(bc, new List<Opportunity> {opportunity});
            batch.finish(bc);
		Test.stopTest();

		Opportunity testOpportunity = [
				SELECT Mandate_Activated__c, Mandate_Last_Modified_Date__c
				FROM Opportunity
				WHERE Id = :opportunity.Id
				LIMIT 1
		];

		System.assertEquals(false, testOpportunity.Mandate_Activated__c);
		System.assertEquals('2020-11-06T13:26:29Z', testOpportunity.Mandate_Last_Modified_Date__c);
    }
}