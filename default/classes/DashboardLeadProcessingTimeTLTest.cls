@isTest
private class DashboardLeadProcessingTimeTLTest {
  public Static User u;
  public Static User u2;
  public Static User u3;
  public Static User u4;
  public Static User u5;
  public Static Lead l;

  @isTest
    public static void testChartfor() {     
      Test.startTest();
        createLeadUser();
      Test.stopTest();

      System.runAs(u) {
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
    }

      System.runAs(u) {
          DashboardLeadProcessingTimeTLCtrl controller = new DashboardLeadProcessingTimeTLCtrl();       
          controller.init();
          controller.getcurrentWeeks();
          controller.changeYear();
          controller.getYears();
          controller.getSecChannels();
      }
    }

    @isTest
    public static void testChartfor2() {     
      Test.startTest();
        createLeadUser();
      Test.stopTest();

      System.runAs(u2) {
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
    }

      System.runAs(u2) {
          DashboardLeadProcessingTimeTLCtrl controller = new DashboardLeadProcessingTimeTLCtrl();
          controller.init();
          controller.getcurrentWeeks();
          controller.changeYear();
      }
    }

    @isTest
    public static void testChartfor3() {     
      Test.startTest();
        createLeadUser();
      Test.stopTest();

      System.runAs(u3) {
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
    }

      System.runAs(u3) {
          DashboardLeadProcessingTimeTLCtrl controller = new DashboardLeadProcessingTimeTLCtrl();
          controller.init();
          controller.getcurrentWeeks();
          controller.changeYear();
      }
    }

    @isTest
    public static void testChartfor4() {     
      Test.startTest();
        createLeadUser();
      Test.stopTest();

      System.runAs(u4) {
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
    }

      System.runAs(u4) {
          DashboardLeadProcessingTimeTLCtrl controller = new DashboardLeadProcessingTimeTLCtrl();
          controller.init();
          controller.getcurrentWeeks();
          controller.changeYear();
      }
    }

    @isTest
    public static void testChartfor5() {     
      Test.startTest();
        createLeadUser();
      Test.stopTest();

      System.runAs(u5) {
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
    }

      System.runAs(u5) {
            DashboardLeadProcessingTimeTLCtrl controller = new DashboardLeadProcessingTimeTLCtrl();       
            controller.init();
            controller.getcurrentWeeks();
            controller.changeYear();
            controller.getYears();
            controller.getSecChannels();
        }
    }

    private static void createLead() {
        List<Lead> leadsList = new List<Lead>();
        l = new Lead(
            LastName = 'test',
            Country = 'France',
            CountryCode = 'FR',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            Phone = '1231231231',
            Site_Agg_product__c = 'test product',
            Company = 'test',
            Quali_Status__c = 'Privatkunde',
            LeadSource = 'Contacted',
            OwnerId = u.Id,
            IsConverted = FALSE,
            Status = 'Open'
        );
        leadsList.add(l);

        Lead l2 = new Lead(
            Status = 'Open',
            LastName = 'test',
            Country = 'Netherlands',
            CountryCode = 'NL',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            Phone = '1231231231',
            Site_Agg_product__c = 'test product',
            Company = 'test',
            First_Call__c = Date.today().addDays(3),
            Quali_Status__c = 'Privatkunde',
            LeadSource = 'Contacted',
            IsConverted = FALSE
        );
        leadsList.add(l2);

        Lead l3 = new Lead(
            Status = 'Open',
            LastName = 'test',
            Country = 'Czech Republic',
            CountryCode = 'CZ',
            Sec_Channel__c = 'Inbound',
            Channel__c = 'Internet',
            Phone = '1231231231',
            Site_Agg_product__c = 'test product',
            Company = 'test',
            First_Call__c = Date.today().addDays(3),
            Quali_Status__c = 'Privatkunde',
            LeadSource = 'Contacted',
            IsConverted = FALSE
        );
        leadsList.add(l3);
        insert leadsList;
        Datetime createdDate = Datetime.newInstance(2017, 4, 13, 5, 0, 0);
        Test.setCreatedDate(l.Id, createdDate);
    }

    @future
    private static void createLeadUser() {
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
      
        u = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
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
        userList.add(u);

        Profile prof = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
        UserRole uRole = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Harte Hank'];
      
        u2 = new User(
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
        userList.add(u2);

        Profile prof3 = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
        UserRole uRole3 = [SELECT Id FROM UserRole WHERE Name = 'CCS Telesales Team Lead'];
        u3 = new User(
            UserRoleId = uRole3.Id,
            ProfileId = prof3.Id,
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
        userList.add(u3);

        Profile prof4 = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
        UserRole uRole4 = [SELECT Id FROM UserRole WHERE Name = 'AllStar Teamleader'];
        u4 = new User(
            UserRoleId = uRole4.Id,
            ProfileId = prof4.Id,
            Username = System.now().millisecond() + '_344423_test2@test.com',
            Alias = 'test',
            Email='test.ti_1233@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='testName',
            Lastname='testFamily',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        userList.add(u4);

        Profile prof5 = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound']; 
        UserRole uRole5 = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound 2'];
        u5 = new User(
            UserRoleId = uRole5.Id,
            ProfileId = prof5.Id,
            Username = System.now().millisecond() + '_344423_test2@test.com',
            Alias = 'test',
            Email='test.ti_1233@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='testName',
            Lastname='testFamily',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        userList.add(u5);
        Database.insert(userList);
    }
}