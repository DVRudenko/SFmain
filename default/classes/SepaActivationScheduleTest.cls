@IsTest
public class SepaActivationScheduleTest {


	/*******************************************************************************
	*  Summary         : test update feed request (Activated)
	*  CreatedDate     : 05/10/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    @isTest
	static void testScheduleQueue() {
		Twikey__c twikeySettings = new Twikey__c(
			Name = 'Test',
			Active__c = true,
			Token__c = '4AF3EAB7D47D13C9CF708C73AB4F9129C224E78B',
			Endpoint__c = 'https://api.beta.twikey.com',
			B2B_Template_Id__c = '1896',
			Core_Template_Id__c = '1897');

		insert twikeySettings;

		Account account = new Account(
			Name = 'Test Account',
			BillingCountry = 'Belgium-NL'
		);

		insert account;

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
			SWIFT_BIC__c = '7654321'
        );

		insert opportunity;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock loginMock = new SingleRequestMock(200, 'Complete', '{"Authorization": "d78bb8a4-483e-4140-8967-748ca8794020"}', new Map<String, String> {'Authorization' => '47de7c97-da18-42dc-a8bd-3864410cd02a'});
            mocksMap.put('https://api.beta.twikey.com/creditor', loginMock);
            SingleRequestMock updateFeedMock = new SingleRequestMock(200, 'Complete', '{"GrpHdr": {"CreDtTm": "2020-11-04T16:30:44Z"},"Messages": [{"Mndt": {"MndtId": "FLEETCORB2BTEST1","LclInstrm": "CORE","Ocrncs": {"SeqTp": "RCUR","Frqcy": "ADHO","Drtn": {"FrDt": "2020-11-05"}},"CdtrSchmeId": "DE17ZZZ00001536434","Cdtr": {"Nm": "FleetCor Belgium BVBA","PstlAdr": {"AdrLine": "Havenlaan 86C bus 204","PstCd": "1000","TwnNm": "Brussel","Ctry": "BE"},"Id": "BE0505807092","CtryOfRes": "BE","CtctDtls": {"EmailAdr": "petr.cermak@fleetcor.eu"}},"Dbtr": {"Nm": "AGNES TESTELMANS","PstlAdr": {"AdrLine": "Test address","PstCd": "1123","TwnNm": "Brugge","Ctry": "BE"},"CtryOfRes": "BE","CtctDtls": {"EmailAdr": "anton.buzak@enway.com"}},"DbtrAcct": "BE68539007547034","DbtrAgt": {"FinInstnId": {"BICFI": "GKCCBEBB","Nm": "BELFIUS BANK"}},"RfrdDoc": "Conditions générales","SplmtryData": [{"Key": "TRACKER","Value": "apM3"},{"Key": "SignerMethod#0","Value": "mock"},{"Key": "Signer#0","Value": "Twikey Mock Signer"},{"Key": "SignerPlace#0","Value": "Minsk"},{"Key": "SignerDate#0","Value": "2020-11-05T12:12:08Z"},{"Key": "FirstName","Value": "AGNES"},{"Key": "LastName","Value": "TESTELMANS"},{"Key": "Language","Value": "fr"},{"Key": "MandateName","Value": "SEPA CORE domiciliation pour Fleetcor BE - Test"},{"Key": "TemplateId","Value": 1897}]},"EvtTime": "2020-11-05T12:12:46Z"}]}', null);
            mocksMap.put('https://api.beta.twikey.com/creditor/mandate', updateFeedMock);
			HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			SchedulableContext sc;
            SepaActivationSchedule schedule = new SepaActivationSchedule();
			SepaActivationSchedule.ExecuteQueue queue = new SepaActivationSchedule.ExecuteQueue();
			QueueableContext context;
			queue.execute(context);
		Test.stopTest();
    }


	/*******************************************************************************
	*  Summary         : test update feed request (Activated)
	*  CreatedDate     : 05/10/2020 by Anton Buzak
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
    @isTest
	static void testSchedule() {
        Test.startTest();
			SepaActivationSchedule sepaActivationSchedule = new SepaActivationSchedule();
			String sch = '0 10 13 * * ?';
			System.schedule('Test SEPA activation job', sch, sepaActivationSchedule);
		Test.stopTest();
    }
}