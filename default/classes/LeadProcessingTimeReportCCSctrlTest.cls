@isTest
private class LeadProcessingTimeReportCCSctrlTest {
	public static User telesalesTeamLeadUser;
	public static User smeTeamLeadUser;
	public static Lead newLeadTeleSales;
	public static Lead newLeadSME;


    @isTest
    public static void detailReportTest() { 
    	Test.startTest();
	    	createUsers();
	  	Test.stopTest();

	  	System.runAs(telesalesTeamLeadUser) {
	  		ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Inbound in bh');
      		createLead();

        	Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2017');
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	          	Name = 'September', 
	          	Start_Date__c = Date.newInstance(2017, 9, 1),
	          	End_Date__c = Date.newInstance(2017, 9, 30),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(2017, 9, 1),
	          	End_Date__c = Date.newInstance(2017, 9, 7),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        LeadProcessingTimeReportCCSctrl controller = new LeadProcessingTimeReportCCSctrl();
	        ApexPages.currentPage().getParameters().put('start','2016-6-19');
	        ApexPages.currentPage().getParameters().put('end', '2016-6-29');
	        ApexPages.currentPage().getParameters().put('country','Germany');
	        ApexPages.currentPage().getParameters().put('userId', telesalesTeamLeadUser.Id);
	        controller.init();
	  	} 

	  	System.runAs(smeTeamLeadUser) {
	  		ApexPages.CurrentPage().getparameters().put('selectedSecChannel', 'Inbound in bh');
      		createLead();

	        Fleetcor_Calendar_Year__c year = new Fleetcor_Calendar_Year__c(Name = '2017');
	        insert year;

	        Fleetcor_Calendar_Month__c month = new Fleetcor_Calendar_Month__c(
	          	Name = 'September', 
	          	Start_Date__c = Date.newInstance(2017, 9, 1),
	          	End_Date__c = Date.newInstance(2017, 9, 30),
	          	Fleetcor_Calendar_Year__c = year.Id);
	        insert month;

	        Fleetcor_Calendar_Week__c week = new Fleetcor_Calendar_Week__c(
	          	Start_Date__c = Date.newInstance(2017, 9, 1),
	          	End_Date__c = Date.newInstance(2017, 9, 7),
	          	Fleetcor_Calendar_Month__c = month.Id);
	        insert week;

	        Sales_Plan__c plan = new Sales_Plan__c(User__c = UserInfo.getUserId(), Fleetcor_Calendar_Month__c = month.Id);
	        insert plan;

	        LeadProcessingTimeReportCCSctrl controller = new LeadProcessingTimeReportCCSctrl();
	        ApexPages.currentPage().getParameters().put('start','2016-6-19');
	        ApexPages.currentPage().getParameters().put('end', '2016-6-29');
	        ApexPages.currentPage().getParameters().put('country','Germany');
	        ApexPages.currentPage().getParameters().put('userId', smeTeamLeadUser.Id);
	        controller.init();
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
	        OwnerId = telesalesTeamLeadUser.Id,
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
	        OwnerId = smeTeamLeadUser.Id,
	        IsConverted = FALSE,
	        Status = 'Contacted',
	        Disable_for_Processing_Time__c = FALSE);
        leadsList.add(newLeadSME);
        insert leadsList;
    }
}