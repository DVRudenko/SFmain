@isTest
public class EmailLeadToSupportTest {
	@isTest
	public static void myTest() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Austria',
			CountryCode = 'AT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest2() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Belgium-NL',
			CountryCode = 'BENL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest3() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Belgium-FR',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest4() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Netherlands',
			CountryCode = 'NL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}


	@isTest
	public static void myTest5() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'France',
			CountryCode = 'FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}


	@isTest
	public static void myTest6() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Hungary',
			CountryCode = 'HU',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest7() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Poland',
			CountryCode = 'PL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest8() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Germany',
			CountryCode = 'DE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest9() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Slovakia',
			CountryCode = 'SK',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest10() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Czech Republic',
			CountryCode = 'CZ',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest11() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Luxembourg',
			CountryCode = 'LU',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest12() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Switzerland-IT',
			CountryCode = 'CHIT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest13() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Switzerland-FR',
			CountryCode = 'CHFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}

	@isTest
	public static void myTest14() {
		Lead l = new Lead(
			LastName = 'test',
			Country = 'Switzerland-DE',
			CountryCode = 'CHDE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			Description = 'test');
		insert l;
		Apexpages.currentPage().getParameters().put('leadId', l.Id);

		EmailLeadToSupport controller = new EmailLeadToSupport();
		controller.sendEmailToSupport();
	}
}