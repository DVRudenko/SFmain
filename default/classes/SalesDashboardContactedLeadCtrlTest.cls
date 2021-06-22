// case1 - lead ownerID = id current user and the user has created a task for this lead
// case2 - lead ownerID = id current user and the user has created a task for this lead, type task = 'Complete'
// case3 - lead ownerID = id current user and lead has no tasks
// case4 - lead ownerID = id current user and the lead has created the task, type task = 'Anruf', task status = 'Not Started'
// case5 - lead ownerID = id teamleader and lead has no tasks

@isTest
private class SalesDashboardContactedLeadCtrlTest {
	public Static User u;
	public Static User u2;
	public Static Lead newLead;
	public Static Task newTask;

	@isTest
    public static void testSalesContactedLeadsDashboardCase1() {
        Test.startTest();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u) {
			createLead();
			createTask();
			newLead.OwnerId = u.Id;
			update newLead;
			newTask.WhoId = newLead.Id;
			newTask.OwnerId = newLead.OwnerId;
			update newTask;

			SalesDashboardContactedLeadCtrl controller = new SalesDashboardContactedLeadCtrl();
		    controller.init();
		    System.assertEquals(1, controller.leadsWithTasksForSales);
		}
	}

	@isTest
    public static void testSalesContactedLeadsDashboardCase2() {
        Test.startTest();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u) {
			createLead();
	    	createTask();
	        newLead.OwnerId = u.Id;
	        update newLead;
	        newTask.WhoId = newLead.Id;
	        newTask.OwnerId = newLead.OwnerId;
	        newTask.Type = 'Completed';
	        update newTask;

			SalesDashboardContactedLeadCtrl controller = new SalesDashboardContactedLeadCtrl();
		    controller.init();
		    System.assertEquals(1, controller.leadsWithTasksForSales);
		}
	}

	@isTest
    public static void testSalesContactedLeadsDashboardCase3() {
        Test.startTest();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u) {
			createLead();
	        newLead.OwnerId = u.Id;
	        update newLead;

			SalesDashboardContactedLeadCtrl controller = new SalesDashboardContactedLeadCtrl();
		    controller.init();
		    System.assertEquals(1, controller.leadsNoTasksForSales);
		}
	}

	@isTest
    public static void testSalesContactedLeadsDashboardCase4() {
        Test.startTest();
			createSalesUser();
		Test.stopTest();

	    System.runAs(u) {
			createLead();
			createTask();
	        newLead.OwnerId = u.Id;
	        update newLead;
	        newTask.WhoId = newLead.Id;
	        newTask.OwnerId = newLead.OwnerId;
	        newTask.Status = 'Not Started';
	        update newTask;

			SalesDashboardContactedLeadCtrl controller = new SalesDashboardContactedLeadCtrl();
		    controller.init();
		    System.assertEquals(1, controller.leadsWithTasksForSales);
		}
	}

	@isTest
    public static void testTeamleadContactedLeadsDashboardCase5() {
        Test.startTest();
			createLeadUser();
		Test.stopTest();

	    System.runAs(u2) {
			createLead();
			newLead.OwnerId = u2.Id;
			update newLead;

			SalesDashboardContactedLeadCtrl controller = new SalesDashboardContactedLeadCtrl();
		    controller.init();
		}
	}

	@isTest
    public static void testTeamleadContactedLeadsDashboardCase6() {
        Test.startTest();
			createCCSLeadUser();
		Test.stopTest();

	    System.runAs(u2) {
			createLead();
			newLead.OwnerId = u2.Id;
			update newLead;

			SalesDashboardContactedLeadCtrl controller = new SalesDashboardContactedLeadCtrl();
		    controller.init();
		}
	}

    @future
	private static void createSalesUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Sales Inbound']; 
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Inbound'];
		
		u = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_123_test1@test.com',
		   	Alias = 'tnu',
			Email = 'test_sales@test.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'testFirstName',
			Lastname = 'testLastName',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(u);	   
	}

	@future
	private static void createLeadUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
		
		u2 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_45_test2@test.com',
		   	Alias = 'tntl',
			Email = 'test_teamlead@test.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'John',
			Lastname = 'Johnson',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(u2);
	}

	@future
	private static void createCCSLeadUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
		UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS SME Team Lead'];
		
		u2 = new User(
			UserRoleId = ur.Id,
			ProfileId = p.Id,
			Username = System.now().millisecond() + '_45_test2@test.com',
		   	Alias = 'tntl',
			Email = 'test_teamlead@test.com',
			EmailEncodingKey = 'UTF-8',
			Firstname = 'John',
			Lastname = 'Johnson',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago'
		);
		Database.insert(u2);
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