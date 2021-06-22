@isTest
private class LeadConversionCarnetctrlTest {
    public static Lead newlead;
    public static User u;
    public String leadId;
    public Boolean isFilled;
    
    @isTest
    static void testConvertLead2() {
        createUser();

        System.runAs(u) {
            createLead2();

          Task task = new Task(
            WhoId = newlead.Id);
          insert task;
            User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(usr) { 
              ApexPages.CurrentPage().getparameters().put('id', newlead.Id);
              LeadConversionCarnetctrl controller = new LeadConversionCarnetctrl();
              controller.init();
                Test.startTest();
                  update newlead;
                    controller.convertLead();
                    controller.cancel();
                    controller.next();
                Test.stopTest();
                
                System.assert( newlead  != null);

            }
        }
    }
    
    @isTest
    static void testConvertLead() {
        createUser();

        System.runAs(u) {
            createLead();

          Task task = new Task(
            WhoId = newlead.Id);
          insert task;
            User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(usr) { 
              ApexPages.CurrentPage().getparameters().put('id', newlead.Id);
              LeadConversionCarnetctrl controller = new LeadConversionCarnetctrl();
              controller.init();
              newlead.Beschaeftigte__c = '1-4';
                Test.startTest();
                  update newlead;
                    controller.convertLead();
                    controller.cancel();
                    controller.next();
                Test.stopTest();
                
                System.assert( newlead  != null);

            }
        }
    }
    
    private static void createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Inbound']; 
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Teamleiter Inbound'];
        
        u = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_23423_test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne_1233@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(u);
    }
    
    private static void createLead() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Carnet' AND sObjectType = 'Lead' LIMIT 1];
        newlead = new Lead(
            LastName = 'Test',
            FirstName = 'testName',
            RecordTypeId = rt.Id,
            OwnerId = u.Id,
            Account_Status__c = 'Prospect',
            Company = 'Test',
            Country = 'Poland',
            Street = 'test',
            City = 'test',
            PostalCode = '223141',
            Salutation = 'Herr',
            Email = 'test@test.com',
            Anzahl_der_Fahrzeuge__c = 2,
            Beschaeftigte__c = '1-4',
            Branche_NACE__c = 'Apotheken - 4773',
            Product__c = 'Carnet Standard 2019',
            CCS_Number_of_GPS_units__c = 1,
            Monatlicher_Kraftstoffverbrauch_in_Liter__c = 1);
        insert newlead;
    }
    
    private static void createLead2() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Endkunde' AND sObjectType = 'Lead' LIMIT 1];
        newlead = new Lead(
            LastName = 'Test',
            FirstName = 'testName',
            Account_Status__c = 'Prospect',
            RecordTypeId = rt.Id,
            OwnerId = u.Id,
            Company = 'Test',
            Country = 'Poland',
            Product__c = 'Shell Basic 2020');
        insert newlead;
    }
    
}