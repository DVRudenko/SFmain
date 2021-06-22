@IsTest
public class SepaActivationCtrlTest {


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

        ApexPages.currentPage().getParameters().put('mandateNumber', account.UMR__c);
		ApexPages.currentPage().getParameters().put('status', 'ok');

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

        SepaActivationCtrl ctrl = new SepaActivationCtrl();
        ctrl.init();

		Opportunity testOpportunity = [
				SELECT SEPA_Request_Approved__c
				FROM Opportunity
				WHERE Id = :opportunity.Id
				LIMIT 1
		];

		System.assertEquals(true, testOpportunity.SEPA_Request_Approved__c);
		System.assertEquals(Limits.getEmailInvocations(), 1);
    }
}