@isTest
private class LeadRelocationServiceTest {
	@isTest
	public static void testService() {
		createCustomSettings();
		List<Lead> leadsToInsert = new List<Lead>();

		Lead l = new Lead(
			LastName = 'test',
			CountryCode = 'AT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l);

		Lead l2 = new Lead(
			LastName = 'test',
			CountryCode = 'DE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l2);

		Lead l3 = new Lead(
			LastName = 'test',
			CountryCode = 'PL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l3);

		Lead l4 = new Lead(
			LastName = 'test',
			CountryCode = 'FR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l4);

		Lead l5 = new Lead(
			LastName = 'test',
			CountryCode = 'HU',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l5);

		Lead l6 = new Lead(
			LastName = 'test',
			CountryCode = 'NL',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l6);

		Lead l7 = new Lead(
			LastName = 'test',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l7);

		Lead l9 = new Lead(
			LastName = 'test',
			CountryCode = 'CHDE',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l9);

		Lead l10 = new Lead(
			LastName = 'test',
			CountryCode = 'CHIT',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l10);

		Lead l10chit = new Lead(
			LastName = 'test',
			CountryCode = 'CHIT',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l10chit);

		Lead l10chfr = new Lead(
			LastName = 'test',
			CountryCode = 'CHFR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l10chfr);

		Lead l10lu = new Lead(
			LastName = 'test',
			CountryCode = 'LU',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l10lu);

		Lead l10cz = new Lead(
			LastName = 'test',
			CountryCode = 'CZ',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l10cz);

		Lead l11 = new Lead(
			LastName = 'test',
			CountryCode = 'CHFR',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l11);

		Lead l12 = new Lead(
			LastName = 'test',
			CountryCode = 'LU',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l12);

		Lead l13 = new Lead(
			LastName = 'test',
			CountryCode = 'CZ',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l13);

		Lead l14 = new Lead(
			LastName = 'test',
			CountryCode = 'SK',
			Sec_Channel__c = 'Inbound',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l14);

		Lead l15 = new Lead(
			LastName = 'test',
			CountryCode = 'BENL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l15);

		Lead l16 = new Lead(
			LastName = 'test',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l16);

		Lead l17 = new Lead(
			LastName = 'test',
			CountryCode = 'FR',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l17);

		Lead l18 = new Lead(
			LastName = 'test',
			CountryCode = 'NL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l18);

		Lead l19 = new Lead(
			LastName = 'test',
			CountryCode = 'CZ',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l19);

		Lead l20 = new Lead(
			LastName = 'test',
			CountryCode = 'SK',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l20);

		Lead l21 = new Lead(
			LastName = 'test',
			CountryCode = 'HU',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l21);

		Lead l22 = new Lead(
			LastName = 'test',
			CountryCode = 'PL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l22);

		Lead l22CHDE = new Lead(
				LastName = 'test',
				CountryCode = 'CHDE',
				Sec_Channel__c = 'JITB',
				Channel__c = 'Internet',
				Phone = '1231231231',
				Company = 'test');
		leadsToInsert.add(l22CHDE);

		Lead l22CHFR = new Lead(
				LastName = 'test',
				CountryCode = 'CHFR',
				Sec_Channel__c = 'JITB',
				Channel__c = 'Internet',
				Phone = '1231231231',
				Company = 'test');
		leadsToInsert.add(l22CHFR);

		Lead l23 = new Lead(
			LastName = 'test',
			CountryCode = 'SK',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l23);

		Lead l24 = new Lead(
			LastName = 'test',
			CountryCode = 'HU',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l24);

		Lead l25 = new Lead(
			LastName = 'test',
			CountryCode = 'PL',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l25);

		Lead l26 = new Lead(
			LastName = 'test',
			CountryCode = 'DE',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l26);

		Lead l27 = new Lead(
			LastName = 'test',
			CountryCode = 'AT',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l27);

		Lead l28 = new Lead(
			LastName = 'test',
			CountryCode = 'CHDE',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l28);

		Lead l29 = new Lead(
			LastName = 'test',
			CountryCode = 'BENL',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l29);

		Lead l30 = new Lead(
			LastName = 'test',
			CountryCode = 'NL',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l30);

		Lead l31 = new Lead(
			LastName = 'test',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l31);

		Lead l32 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Webform',
				Phone = '+71231231231',
				Company = 'test');
		leadsToInsert.add(l32);

		Lead l33 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Email',
				Phone = '+71231231231',
				Company = 'test');
		leadsToInsert.add(l33);

		Lead l34 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Chat',
				Phone = '+71231231231',
				Company = 'test');
		leadsToInsert.add(l34);

		Lead l35 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Popup',
				Phone = '+71231231231',
				Company = 'test');
		leadsToInsert.add(l35);
		Lead l36 = new Lead(
				LastName = 'test',
				CountryCode = 'RU',
				Country = 'Russia',
				Lead_Source_Type__c = 'Webform',
				Phone = '+71231231231',
				Company = 'test',
				Source_of_Lead__c = 'Сайт Petrolplus.ru');
		leadsToInsert.add(l36);

		RecordType allstarLeadRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'AllStar' AND SobjectType = 'Lead'
                LIMIT 1];

        Lead l37 = new Lead(
			LastName = 'test',
			CountryCode = 'BEFR',
			Sec_Channel__c = 'Partner',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test',
			RecordTypeId = allstarLeadRecordType.Id);
		leadsToInsert.add(l37);

		Lead l38 = new Lead(
			LastName = 'test',
			CountryCode = 'PL',
			Sec_Channel__c = 'JITB',
			Channel__c = 'Internet',
			Phone = '1231231231',
			Company = 'test');
		leadsToInsert.add(l38);

		insert leadsToInsert;

		Datetime dd = Datetime.now().addMinutes(-15);
		for (Lead ll : leadsToInsert) {
			Test.setCreatedDate(ll.Id, dd);
		}

		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
		LocaleSidKey='en_US', ProfileId = p.Id,
		TimeZoneSidKey='America/Los_Angeles', UserName='standarduser-flt123@testorg.com');
		insert u;

		for (Lead ll : leadsToInsert) {
			ll.OwnerId = u.Id;
		}

		update leadsToInsert;
	}

	@isTest
	public static void testAdoptionDeals() {
		createCustomSettings();
		// do not add next leads to list cause need to test adoption deals
		Test.startTest();
			Lead shellEmailLead = new Lead(
					Sec_Channel__c = 'Inbound',
					Channel__c = 'E-mail',
					LeadSource = 'Shell Email',
					Phone = '32132132',
					Email = 'fook@floyd.com',
					Company = 'YOLO',
					Country = 'Belgium-FR',
					CountryCode = 'BEFR',
					Salutation = 'Mr',
					FirstName = 'fook',
					LastName = 'floyd',
					CCS_number_of_cards__c = 2
			);
			insert shellEmailLead;

			Lead facebookLead = new Lead(
					Sec_Channel__c = 'Inbound',
					Channel__c = 'E-mail',
					LeadSource = 'Facebook',
					Phone = '32132132',
					Email = 'fook@floyd.com',
					Company = 'YOLO',
					Country = 'Belgium-NL',
					CountryCode = 'BENL',
					Salutation = 'Mr',
					FirstName = 'fook',
					LastName = 'floyd',
					Number_of_Cards_facebook__c = '2'
			);
			insert facebookLead;

			Lead tabletFormLead = new Lead(
					Sec_Channel__c = 'Inbound',
					Channel__c = 'E-mail',
					LeadSource = 'Tablet Short Form',
					Phone = '32132132',
					Email = 'fook@floyd.com',
					Company = 'YOLO',
					Country = 'Germany',
					CountryCode = 'DE',
					Salutation = 'Mr',
					FirstName = 'fook',
					LastName = 'floyd',
					CCS_number_of_cards__c = 2
			);
			insert tabletFormLead;

			Account partnerAccount = new Account(
					Name = 'test',
					OBN__c = '9897',
					BillingCountry = 'Germany');
			insert partnerAccount;

			Lead partnerJITBLeadDE = new Lead(
					Sec_Channel__c = 'JITB',
					Channel__c = 'Internet',
					LeadSource = 'Partner',
					Phone = '32132132',
					Email = 'fook@floyd.com',
					Company = 'YOLO',
					Country = 'Germany',
					CountryCode = 'DE',
					Salutation = 'Mr',
					FirstName = 'fook',
					LastName = 'floyd',
					Anzahl_der_Fahrzeuge__c = 2,
					Partner__c = partnerAccount.Id,
					Partner_OBN__c = '9897'
			);
			insert partnerJITBLeadDE;

			Lead partnerJITBLeadCHDE = new Lead(
					Sec_Channel__c = 'JITB',
					Channel__c = 'Internet',
					LeadSource = 'Partner',
					Phone = '32132132',
					Email = 'fook@floyd.com',
					Company = 'YOLO',
					Country = 'Switzerland-DE',
					CountryCode = 'CHDE',
					Salutation = 'Mr',
					FirstName = 'fook',
					LastName = 'floyd',
					CCS_number_of_cards__c = 2,
					Partner__c = partnerAccount.Id,
					Partner_OBN__c = '9897'
			);
			insert partnerJITBLeadCHDE;
		Test.stopTest();
	}

	public static void createCustomSettings() {
		List<Lead_Switched_To_E2E__c> leadSwitchedToE2EList = new List<Lead_Switched_To_E2E__c>();
		for (String country : GlobalUtils.countryCodeToCountryMap.values()) {
			Lead_Switched_To_E2E__c switchedToE2ESettings = new Lead_Switched_To_E2E__c(
					Name = country,
					Min_Cards__c = 1,
					Max_Cards__c = 2);
			leadSwitchedToE2EList.add(switchedToE2ESettings);

			Lead_Switched_To_E2E__c switchedToE2EJITBSettings = new Lead_Switched_To_E2E__c(
					Name = country + 'JITB',
					Min_Cards__c = 1,
					Max_Cards__c = 2);
			leadSwitchedToE2EList.add(switchedToE2EJITBSettings);
		}
		insert leadSwitchedToE2EList;

		LeadRelocationSettings__c leadRelocationSettings = new LeadRelocationSettings__c(EU_Enabled__c = true);
		insert leadRelocationSettings;
	}
}