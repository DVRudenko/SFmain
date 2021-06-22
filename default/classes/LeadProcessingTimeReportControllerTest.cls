@isTest
private class LeadProcessingTimeReportControllerTest {
	public Static User u1;
	public Static User u2;
	public Static User u3;
	public Static User u4;
	public Static User u5;
	public Static Lead l;

	@isTest
    public static void testChartforHH() {     
	  	Test.startTest();
	    	createLeadUser();
	  	Test.stopTest();

      	System.runAs(u1) {
      		ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Inbound not in bh');
      		createLead();

        	Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2016');
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
          		Name = 'April', 
	          	Start_Date__c = Date.today(), 
	          	End_Date__c = Date.today(),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.today(), 
	          	End_Date__c = Date.today(),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        BusinessHours defaultBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'Default'
                LIMIT 1];
    	}

      System.runAs(u1) {
          	LeadProcessingTimeReportController controller = new LeadProcessingTimeReportController();
	        ApexPages.currentPage().getParameters().put('start','2016-6-19');
	        ApexPages.currentPage().getParameters().put('end', '2016-6-29');
	        ApexPages.currentPage().getParameters().put('country','Austria');
	        ApexPages.currentPage().getParameters().put('userId', u1.Id);
	        controller.init();
      	}
    }

    @isTest
    public static void testChartforInbound() {     
	  	Test.startTest();
	    	createLeadUser();
	  	Test.stopTest();

      	System.runAs(u2) {
      		ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Inbound in bh');
      		createLead();

        	Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2016');
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
          		Name = 'April', 
	          	Start_Date__c = Date.today(), 
	          	End_Date__c = Date.today(),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.today(), 
	          	End_Date__c = Date.today(),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        BusinessHours defaultBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'Default'
                LIMIT 1];
    	}

      System.runAs(u2) {
          	LeadProcessingTimeReportController controller = new LeadProcessingTimeReportController();
	        ApexPages.currentPage().getParameters().put('start','2016-6-19');
	        ApexPages.currentPage().getParameters().put('end', '2016-6-29');
	        ApexPages.currentPage().getParameters().put('country','Austria');
	        ApexPages.currentPage().getParameters().put('userId', u2.Id);
	        controller.init();
	        ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Inbound not in bh');
	        controller.init();
	        ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Inbound Total');
	        controller.init();
      	}
    }

    @isTest
    public static void testChartforPartner() {     
	  	Test.startTest();
	    	createLeadUser();
	  	Test.stopTest();

      	System.runAs(u2) {
      		ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Partner in bh');
      		createLead();

        	Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2016');
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
          		Name = 'April', 
	          	Start_Date__c = Date.today(), 
	          	End_Date__c = Date.today(),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.today(), 
	          	End_Date__c = Date.today(),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        BusinessHours defaultBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'Default'
                LIMIT 1];
    	}

  		System.runAs(u2) {
          	LeadProcessingTimeReportController controller = new LeadProcessingTimeReportController();
	        ApexPages.currentPage().getParameters().put('start','2016-6-19');
	        ApexPages.currentPage().getParameters().put('end', '2016-6-29');
	        ApexPages.currentPage().getParameters().put('country','Germany');
	        ApexPages.currentPage().getParameters().put('userId', u2.Id);
	        controller.init();
	        ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Partner not in bh');
	        controller.init();
	        ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Partner Total');
	        controller.init();
      	}
    }

    @isTest
    public static void testChartforCCS() {     
	  	Test.startTest();
	    	createLeadUser();
	  	Test.stopTest();

      	System.runAs(u3) {
      		ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'JITB not in bh');
      		createLead();

        	Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2017');
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
          		Name = 'April', 
	          	Start_Date__c = Date.newInstance(2017, 3, 27), 
	          	End_Date__c = Date.newInstance(2017, 4, 23),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(2017, 3, 27),  
	          	End_Date__c = Date.newInstance(2017, 4, 2), 
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        BusinessHours defaultBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'Default'
                LIMIT 1];
    	}

      System.runAs(u3) {
      		List<Lead> leadsList = [
      				SELECT Sec_Channel__c, Channel__c, Country, OwnerId, First_Call__c, LeadSource, Quali_Status__c, Disable_for_Processing_Time__c
      				FROM Lead];
          	LeadProcessingTimeReportController controller = new LeadProcessingTimeReportController();
	        ApexPages.currentPage().getParameters().put('start','2017-3-27');
	        ApexPages.currentPage().getParameters().put('end', '2017-4-2');
	        ApexPages.currentPage().getParameters().put('country','Czech Republic');
	        ApexPages.currentPage().getParameters().put('userId', u3.Id);
	        controller.init();
      	}
    }

    @isTest
    public static void testChartforInbound2() {     
	  	Test.startTest();
	    	createLeadUser();
	  	Test.stopTest();

      	System.runAs(u4) {
      		ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Inbound Total');
      		createLead();

        	Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2016');
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
          		Name = 'April', 
	          	Start_Date__c = Date.today(), 
	          	End_Date__c = Date.today(),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.today(), 
	          	End_Date__c = Date.today(),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        BusinessHours defaultBH = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'Default'
                LIMIT 1];
    	}

      System.runAs(u4) {
          	LeadProcessingTimeReportController controller = new LeadProcessingTimeReportController();
	        ApexPages.currentPage().getParameters().put('start','2016-6-19');
	        ApexPages.currentPage().getParameters().put('end', '2016-6-29');
	        ApexPages.currentPage().getParameters().put('country','Austria');
	        ApexPages.currentPage().getParameters().put('userId', u4.Id);
	        controller.init();
	        ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Total');
	        controller.init();
	        ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'JITB Total');
	        controller.init();
	        ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'JITB in bh');
	        controller.init();
      	}
    }

    private static void createLead() {
    	List<GroupMember> members = [
            SELECT UserOrGroupId
            FROM GroupMember
            WHERE Group.Name = 'LeadAssignDE'
            LIMIT 1];

      User usr = [SELECT Name FROM User WHERE Id = :members.get(0).UserOrGroupId];
        l = new Lead (
      		LastName = 'test',
	        Country = 'Austria',
	        Sec_Channel__c = 'Inbound',
	        Channel__c = 'Internet',
	        Phone = '+71231231231',
	        Company = 'test',
	        Site_Agg_product__c = 'test product',
	        Quali_Status__c = 'Privatkunde',
	        LeadSource = 'Contacted',
	        OwnerId = usr.Id,
	        IsConverted = FALSE,
	        Status = 'Open',
	        Disable_for_Processing_Time__c = FALSE,
          	First_Call__c = DateTime.newInstance(2016, 6, 28, 15, 35, 0));
        insert l;
        Datetime createdDate = Date.today();
 		Test.setCreatedDate(l.Id, createdDate);

        Datetime customCreatedDate = DateTime.newInstance(2017, 4, 13, 5, 0, 0);
        Test.setCreatedDate(l.Id, customCreatedDate);
    }

    @future
    private static void createLeadUser() {
    	List<User> usersList = new List<User>();
	    Profile prof = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
      	UserRole uRole = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Harte Hank'];
      
      	u1 = new User(
	        UserRoleId = uRole.Id,
	        ProfileId = prof.Id,
	        Username = System.now().millisecond() + '_23423_test2@test.com',
	        Alias = 'test',
	        Email='test.ti_1233@wayneenterprises.com',
	        EmailEncodingKey='UTF-8',
	        Firstname='testName',
	        Lastname='testFamily',
	        LanguageLocaleKey='en_US',
	        LocaleSidKey='en_US',
	        TimeZoneSidKey='America/Chicago'
	      	);
      	usersList.add(u1);

      	Profile pf = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound']; 
      	UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
      	u2 = new User(
	        UserRoleId = userRole.Id,
	        ProfileId = pf.Id,
	        Username = System.now().millisecond() + '_22133443_test2@test.com',
	        Alias = 'test2',
	        Email='test2.ti_1233@wayneenterprises.com',
	        EmailEncodingKey='UTF-8',
	        Firstname='testName2',
	        Lastname='testFamily2',
	        LanguageLocaleKey='en_US',
	        LocaleSidKey='en_US',
	        TimeZoneSidKey='America/Chicago'
	      	);
      	usersList.add(u2);

      	Profile prof3 = [SELECT Id FROM Profile WHERE Name='CCS SME Team Lead'];
        UserRole uRole3 = [SELECT Id FROM UserRole WHERE Name = 'CCS Telesales Team Lead'];
      	u3 = new User(
	        UserRoleId = uRole3.Id,
	        ProfileId = prof3.Id,
	        Username = System.now().millisecond() + '_22133443_test2@test.com',
	        Alias = 'test2',
	        Email='test2.ti_1233@wayneenterprises.com',
	        EmailEncodingKey='UTF-8',
	        Firstname='testName2',
	        Lastname='testFamily2',
	        LanguageLocaleKey='en_US',
	        LocaleSidKey='cs_CZ',
	        TimeZoneSidKey='Europe/Berlin'
	      	);
      	usersList.add(u3);

      	Profile pr4 = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound']; 
      	UserRole uRole4 = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound 2'];
      	u4 = new User(
	        UserRoleId = uRole4.Id,
	        ProfileId = pr4.Id,
	        Username = System.now().millisecond() + '_22133443_test2@test.com',
	        Alias = 'test2',
	        Email='test2.ti_1233@wayneenterprises.com',
	        EmailEncodingKey='UTF-8',
	        Firstname='testName2',
	        Lastname='testFamily2',
	        LanguageLocaleKey='en_US',
	        LocaleSidKey='en_US',
	        TimeZoneSidKey='America/Chicago'
	      	);
      	usersList.add(u4);

      	Database.insert(usersList);
  	}
}