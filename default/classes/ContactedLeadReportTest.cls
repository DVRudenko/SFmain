@isTest
private class ContactedLeadReportTest {
	public Static Lead newLead;
	public Static Task newTask;

    @isTest
    public static void testSalesReportCase1() {
    	createLead();
    	createTask();
        String userId = [Select Id From User WHERE UserRole.Name = 'Salesteam Inbound' AND isActive = true LIMIT 1].Id;
        newLead.OwnerId = userId;
        update newLead;
        newTask.WhoId = newLead.Id;
        newTask.OwnerId = newLead.OwnerId;
    	update newTask;

        ContactedLeadReport controller = new ContactedLeadReport();
        controller.selectedUserId = userId;
	    controller.init();
	    System.assertEquals(1, controller.numberOfLeadsWithTasks);
    }

    @isTest
    public static void testSalesReportCase2() {
    	createLead();
    	createTask();
        String userId = [Select Id From User WHERE UserRole.Name = 'Salesteam Inbound' AND isActive = true LIMIT 1].Id;
        newLead.OwnerId = userId;
        update newLead;
        newTask.WhoId = newLead.Id;
        newTask.OwnerId = newLead.OwnerId;
        newTask.Type = 'Completed';
        update newTask;

        ContactedLeadReport controller = new ContactedLeadReport();
        controller.selectedUserId = userId;
	    controller.init();
	    System.assertEquals(1, controller.numberOfLeads);
    }

    @isTest
    public static void testSalesReportCase3() {
    	createLead();
        String userId = [Select Id From User WHERE UserRole.Name = 'Salesteam Inbound' AND isActive = true LIMIT 1].Id;
        newLead.OwnerId = userId;
        update newLead;

        ContactedLeadReport controller = new ContactedLeadReport();
        controller.selectedUserId = userId;
	    controller.init();
	    System.assertEquals(1, controller.numberOfLeads);
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
            Phone = '33333333',
            LeadSource = 'Internet',
            Status = 'Contacted',
            Disable_for_KPI__c = FALSE           
            );
		insert newLead;
	}

	public static void createTask() {
		newTask = new Task(
			Subject = 'Other',
			Priority= 'Normal',
			Status = 'In Progress',
			Type = 'Anruf',
			ActivityDate = Date.today().addDays(-2));
		insert newTask;
	}
}