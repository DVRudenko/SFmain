@isTest
public class FleetmaticsLeadFormCtrlTest {
	@isTest
	public static void createLeadTest() {
		ApexPages.CurrentPage().getparameters().put('externalId', 'nsle45HTlsm2snIJ93NjskO9JiwjcnW5');
		FleetmaticsLeadFormCtrl controller = new FleetmaticsLeadFormCtrl();
		controller.init();
		controller.getLeadSources();
		controller.newLead.Company = 'test';
		controller.newLead.FirstName = 'test';
		controller.newLead.LastName = 'test';
		controller.newLead.Country = 'Russia';
		controller.newLead.Phone = '+71231231230';
		controller.newLead.Email = 'test@test.com';
		controller.ownerEmail = 'test@test.com';
		Fleetmatics_Notifications__c notification = new Fleetmatics_Notifications__c(
			Name = 'test',
			Active__c = true,
			Email__c = 'test@test.com');
		insert notification;
		controller.createLead();
		controller.getCountries();

		List<Lead> leadList = [
				SELECT Id
				FROM Lead
				WHERE Sec_Channel__c = 'Partner' AND Channel__c = 'FLMT_Form' AND LeadSource = 'Fleetmatics_new'];
		System.assertEquals(leadList.size(), 1);

		System.assertEquals(Limits.getEmailInvocations(), 1);
	}
}