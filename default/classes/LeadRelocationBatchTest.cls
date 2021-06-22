@isTest
private class LeadRelocationBatchTest {
	@testSetup
	static void createCustomSetting() {
		LeadRelocationSettings__c leadRelocationSettings = new LeadRelocationSettings__c(EU_Enabled__c = true);
		insert leadRelocationSettings;
	}

    @isTest
    public static void relocationTest() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Austria',
			CountryCode = 'AT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest2() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Germany',
			CountryCode = 'DE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest3() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Netherlands',
			CountryCode = 'NL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest4() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Poland',
			CountryCode = 'PL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;
		
		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest5() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Hungary',
			CountryCode = 'HU',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest6() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'France',
			CountryCode = 'FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest7() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-FR',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest8() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-NL',
			CountryCode = 'BENL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest9() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-FR',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest10DE() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Germany',
			CountryCode = 'DE',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest10BEFR() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-FR',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest10BENL() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-NL',
			CountryCode = 'BENL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest10() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'France',
			CountryCode = 'FR',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest11() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Netherlands',
			CountryCode = 'NL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest12() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Czech Republic',
			CountryCode = 'CZ',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest13() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Slovakia',
			CountryCode = 'SK',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest14() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Hungary',
			CountryCode = 'HU',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest15() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Poland',
			CountryCode = 'PL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest16() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-IT',
			CountryCode = 'CHIT',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest17() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-DE',
			CountryCode = 'CHDE',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest18() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-FR',
			CountryCode = 'CHFR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest19() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Czech Republic',
			CountryCode = 'CZ',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest20() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Hungary',
			CountryCode = 'HU',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest21() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'France',
			CountryCode = 'FR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest22() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-DE',
			CountryCode = 'CHDE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest23() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-IT',
			CountryCode = 'CHIT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest24() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-FR',
			CountryCode = 'CHFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest25() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Luxembourg',
			CountryCode = 'LU',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest26() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Czech Republic',
			CountryCode = 'CZ',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest27() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Slovakia',
			CountryCode = 'SK',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest28() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Switzerland-FR',
			CountryCode = 'CHFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest29() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Belgium-FR',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest30() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Netherlands',
			CountryCode = 'NL',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }

    @isTest
    public static void relocationTest31() {
		Lead l = new Lead(
			LastName = 'test',
			Status = 'Open',
			Country = 'Slovakia',
			CountryCode = 'SK',
			Sec_Channel__c = 'Partner',
			Channel__c = 'FLMT_Form',
			Phone = '1231231231',
			Company = 'test');
		insert l;
		l.Last_Owner_Change_Date__c = Datetime.now().addMinutes(-15);
		update l;

		LeadRelocationBatch newbatch = new LeadRelocationBatch();
		Database.executeBatch(newbatch, 1);
    }
}