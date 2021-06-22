@isTest (SeeAllData = true)
private class LeadHistoryViewControllerTest {
	public static Lead testlead;


    /*******************************************************************************
    *  Name            : testLeadHistoryView()
    *  Summary         : Test Lead History View From Opportunity   
    *  CreatedDate     : 04/12/2017
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    private static void testLeadHistoryView() {
        List<Lead> leadsList = [
            SELECT Id, Name, Status
            FROM Lead
            WHERE Id = '00Q2000000tfNkN'
            LIMIT 1
        ];

        if (! leadsList.isEmpty()) {
            testlead = leadsList.get(0);
            testlead.Salutation = 'Herr';
            testlead.Anzahl_der_Fahrzeuge__c = 123;
            testlead.Email = null;
            update testlead;
        	Database.LeadConvert lc = new Database.LeadConvert();
        	lc.setLeadId(testlead.id);
        	LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        	lc.setConvertedStatus(convertStatus.MasterLabel);
        	Database.LeadConvertResult lcr = Database.convertLead(lc);
        	System.assert(lcr.isSuccess());

        	String opptyId = [SELECT ConvertedOpportunityId FROM Lead WHERE Id = :testlead.Id LIMIT 1].ConvertedOpportunityId;

        	ApexPages.CurrentPage().getparameters().put('id', opptyId);
        	LeadHistoryViewController controller = new LeadHistoryViewController();
        	controller.init();
        }
    }
}