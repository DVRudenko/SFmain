@isTest
private class MassLeadsRecycleExtensionsTest {	
    public static Lead newLead1;
    public static Lead newLead2;
    public static Event newEvent;
    public static Task newTask;

    @isTest
    public static void massLeadsRecycleTest() { 
  		createLeads();
        createEvent();
        createTask();
        List<Lead> leadsList = new List<Lead>();
        leadsList.add(newLead1);
        leadsList.add(newLead2);
        ApexPages.StandardSetController sc = new ApexPages.standardSetController(leadsList);
        sc.setSelected(leadsList);
		MassLeadsRecycleExtensions extensions = new MassLeadsRecycleExtensions(sc);
		extensions.doRecycleLeads();
		Lead updatedLead = [
			SELECT Status, (SELECT Id FROM Tasks WHERE WhoId = :newLead1.Id LIMIT 1) 
			FROM Lead 
			WHERE Id = :newLead1.Id 
			LIMIT 1
		];
		System.assertEquals(0, updatedLead.Tasks.size());
		System.assertEquals('Open', updatedLead.Status);
    }

    private static void createLeads() {
    	List<Lead> leadsToInsertList = new List<Lead>();
		newLead1 = new Lead(
			Country = 'Germany',
            CountryCode = 'DE',
			Company = 'Company test',
			Salutation = 'Herr',
			Anzahl_der_Karten_Euroshell__c = '123',
			Anzahl_der_Fahrzeuge__c = 1, 
			FirstName = 'nameLead', 
			LastName = 'familyLead',  
            Sec_Channel__c = 'Inbound',
            Phone = '3333333',
            LeadSource = 'Internet',
            Status = 'Contacted',
            Disable_for_KPI__c = FALSE           
        );
        leadsToInsertList.add(newLead1);

        newLead2 = new Lead(
			Country = 'Germany',
            CountryCode = 'DE',
			Company = 'Company test2',
			Salutation = 'Herr',
			Anzahl_der_Karten_Euroshell__c = '321',
			Anzahl_der_Fahrzeuge__c = 3, 
			FirstName = 'nameLead2', 
			LastName = 'familyLead2',  
            Sec_Channel__c = 'Inbound',
            Phone = '1111111',
            LeadSource = 'Internet',
            Status = 'Disqualified',
            Disable_for_KPI__c = FALSE           
        );
        leadsToInsertList.add(newLead2);

		insert leadsToInsertList;
	}

    private static void createEvent() {
        newEvent = new Event(
            Subject = 'Test Event',
            Type = 'První schůzka',
            WhoId = newLead1.Id,
            DurationInMinutes = System.now().millisecond() + 1,
            ActivityDateTime = Datetime.now()
        );
        insert newEvent;
    }

    private static void createTask() {
        newTask = new Task(
            Subject = 'Call',
            Priority = 'Normal',
            Status = 'Completed',
            WhoId = newLead1.Id,
            WhatId = null);
        insert newTask;
    }
}