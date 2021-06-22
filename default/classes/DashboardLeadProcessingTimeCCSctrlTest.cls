@isTest
private class DashboardLeadProcessingTimeCCSctrlTest {
	public static User telesalesTeamLeadUser;
	public static User smeTeamLeadUser;
	public static User telesalesUser;
	public static User smeUser;
	public static Lead newLeadTeleSales;
	public static Lead newLeadSME;

	@isTest
    public static void telesalesTeamTest() { 
    	Test.startTest();
        	createUsers();
     	Test.stopTest();

      	System.runAs(telesalesTeamLeadUser) {
	        createLead();

	        Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	          	Name = 'January', 
	          	Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year(), 1, 30),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year(), 1, 7),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;
	        
	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	          	Name = 'January', 
	          	Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 30),
	          	Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 7),
	          	Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert weekOfNextYear;

	        Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert planOfNextYear;

	        DashboardLeadProcessingTimeCCSctrl controller = new DashboardLeadProcessingTimeCCSctrl();       
          	controller.init();
          	controller.getcurrentWeeks();
          	controller.changeYear();
          	controller.getYears();
          	controller.getSecChannels();
    	}      
    }


    @isTest
    public static void telesalesTeamToProcessTest() { 
    	Test.startTest();
        	createUsers();
     	Test.stopTest();

      	System.runAs(telesalesTeamLeadUser) {
	        createLead();
	        newLeadTeleSales.Status = 'Open';
	        update newLeadTeleSales;

	        Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	          	Name = 'January', 
	          	Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year(), 1, 30),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year(), 1, 7),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	          	Name = 'January', 
	          	Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 30),
	          	Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 7),
	          	Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert weekOfNextYear;

	        Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert planOfNextYear;

	        DashboardLeadProcessingTimeCCSctrl controller = new DashboardLeadProcessingTimeCCSctrl(); 
	        controller.selectedPeriod = week.Id;      
          	controller.init();    	
          	controller.getcurrentWeeks();
          	controller.changeYear();
          	controller.getYears();
          	controller.getSecChannels();
    	}      
    }


    @isTest
    public static void smeTeamTest() { 
    	Test.startTest();
        	createUsers();
     	Test.stopTest();

      	System.runAs(smeTeamLeadUser) {
  			createLead();

	        Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year()));
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	          	Name = 'January', 
	          	Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year(), 1, 30),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(Date.today().year(), 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year(), 1, 7),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        //next year
	        Fleetcor_Calendar_Year__c nextYear = new Fleetcor_Calendar_Year__c(Name = String.valueOf(Date.today().year() + 1));
	        insert nextYear;

	        Fleetcor_Calendar_Month__c monthOfNextYear = new Fleetcor_Calendar_Month__c(
	          	Name = 'January', 
	          	Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 30),
	          	Fleetcor_Calendar_Year__c = nextYear.Id);
	        insert monthOfNextYear;

	        Fleetcor_Calendar_Week__c weekOfNextYear = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(Date.today().year() + 1, 1, 1),
	          	End_Date__c = Date.newInstance(Date.today().year() + 1, 1, 7),
	          	Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert weekOfNextYear;

	        Sales_Plan__c planOfNextYear = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = monthOfNextYear.Id);
	        insert planOfNextYear;

	        DashboardLeadProcessingTimeCCSctrl controller = new DashboardLeadProcessingTimeCCSctrl();       
          	controller.init();
          	controller.getcurrentWeeks();
          	controller.changeYear();
          	controller.getYears();
          	controller.getSecChannels();
    	}      
    }

    @future
    private static void createUsers() {
    	List<User> usersList = new List<User>();
    	Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Salesteamleiter Inbound'];
      	UserRole uRole = [SELECT Id FROM UserRole WHERE Name = 'CCS Telesales Team Lead'];
      
      	telesalesTeamLeadUser = new User(
	        UserRoleId = uRole.Id,
	        ProfileId = p1.Id,
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
      	usersList.add(telesalesTeamLeadUser);
 
 		Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Service Manager'];
      	UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'CCS SME Team Lead'];
      	smeTeamLeadUser = new User(
	        UserRoleId = userRole.Id,
	        ProfileId = p2.Id,
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
      	usersList.add(smeTeamLeadUser);

      	Profile p3 = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
        UserRole uRole3 = [SELECT Id FROM UserRole WHERE Name = 'CCS CZ Telesales'];
      	telesalesUser = new User(
	        UserRoleId = uRole3.Id,
	        ProfileId = p3.Id,
	        Username = System.now().millisecond() + '_22133443_test2@test.com',
	        Alias = 'test3',
	        Email='test3.ti_1233@wayneenterprises.com',
	        EmailEncodingKey='UTF-8',
	        Firstname='testName3',
	        Lastname='testFamily3',
	        LanguageLocaleKey='en_US',
	        LocaleSidKey='cs_CZ',
	        TimeZoneSidKey='Europe/Berlin'
	      	);
      	usersList.add(telesalesUser);

      	Profile p4 = [SELECT Id FROM Profile WHERE Name = 'Service Manager'];
      	UserRole uRole4 = [SELECT Id FROM UserRole WHERE Name = 'CCS CZ SME'];
      	smeUser = new User(
	        UserRoleId = uRole4.Id,
	        ProfileId = p4.Id,
	        Username = System.now().millisecond() + '_22133443_test2@test.com',
	        Alias = 'test4',
	        Email='test4.ti_1233@wayneenterprises.com',
	        EmailEncodingKey='UTF-8',
	        Firstname='testName4',
	        Lastname='testFamily4',
	        LanguageLocaleKey='en_US',
	        LocaleSidKey='en_US',
	        TimeZoneSidKey='America/Chicago'
	      	);
      	usersList.add(smeUser);

      	Database.insert(usersList);
  	}

  	private static void createLead() {
  		List<Lead> leadsList = new List<Lead>();
        newLeadTeleSales = new Lead (
      		LastName = 'test',
	        Country = 'Germany',
			CountryCode = 'DE',
	        Sec_Channel__c = 'Inbound',
	        Channel__c = 'web',
	        Phone = '1231231231',
	        Company = 'test',
	        Site_Agg_product__c = 'test product',
	        Quali_Status__c = 'Privatkunde',
	        LeadSource = 'Web CCS',
	        OwnerId = telesalesUser.Id,
	        IsConverted = FALSE,
	        Status = 'Contacted',
	        Disable_for_Processing_Time__c = FALSE);	     
        leadsList.add(newLeadTeleSales);
        

 		newLeadSME = new Lead (
      		LastName = 'test lead',
	        Country = 'Germany',
			CountryCode = 'DE',
	        Sec_Channel__c = 'Inbound',
	        Channel__c = 'web',
	        Phone = '1231231231',
	        Company = 'test',
	        Site_Agg_product__c = 'test product',
	        Quali_Status__c = 'Privatkunde',
	        LeadSource = 'Web CCS',
	        OwnerId = smeUser.Id,
	        IsConverted = FALSE,
	        Status = 'Contacted',
	        Disable_for_Processing_Time__c = FALSE);
        leadsList.add(newLeadSME);
        insert leadsList;
    }
}