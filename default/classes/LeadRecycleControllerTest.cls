@isTest
private class LeadRecycleControllerTest {
	public static Lead newLead;
    public static Event newEvent;
    public static Task newTask;

    @isTest
    public static void leadRecycleTest() { 
  		createLead();
        createEvent();
        createTask();
  		ApexPages.CurrentPage().getparameters().put('id', newLead.Id);
  		LeadRecycleController controller = new LeadRecycleController();
  		controller.init();
    }

    @isTest
    public static void disqualifiedLeadRecycleTest() { 
        createLead();
        createEvent();
        createTask();

        newLead.Status = 'Disqualified';
        update newLead;
        ApexPages.CurrentPage().getparameters().put('id', newLead.Id);
        LeadRecycleController controller = new LeadRecycleController();
        controller.init();
    }

    private static void createLead() {
		newLead = new Lead(
			Country = 'Germany',
            CountryCode = 'DE',
			Company = 'Company test',
			Salutation = 'Herr',
			Anzahl_der_Karten_Euroshell__c = 'test',
			Anzahl_der_Fahrzeuge__c = 1, 
			FirstName = 'nameLead', 
			LastName = 'familyLead',  
            Sec_Channel__c = 'Inbound',
            Phone = '3333333',
            LeadSource = 'Internet',
            Status = 'Contacted',
            Disable_for_KPI__c = FALSE           
            );
		insert newLead;
	}

    private static void createEvent() {
        newEvent = new Event(
            Subject = 'Test Event',
            Type = 'První schůzka',
            WhoId = newLead.Id,
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
            WhoId = newLead.Id,
            WhatId = null);
        insert newTask;
    }
}