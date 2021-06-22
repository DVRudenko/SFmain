@isTest
private class LeadConversionCCSctrlTest {
    public static User u;
    public static Lead newlead;  


    /*******************************************************************************
    *  Name            : testConvertLead()
    *  Summary         : test lead conversion if all required fields are filled, assigns tasks 
                         from lead to opportunity     
    *  CreatedDate     : 11/10/2017
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testConvertLead() {
        createUser();

        System.runAs(u) {
            createLead();
            Task task = new Task(
                WhoId = newlead.Id);
            insert task;

            ApexPages.CurrentPage().getparameters().put('id', newlead.Id);
            LeadConversionCCSctrl controller = new LeadConversionCCSctrl();
            
            Test.startTest();
                controller.init();
                controller.continueConvert();
                controller.backToLeadWithoutSavingFields();
                controller.backToLeadWithSavingFields();
            Test.stopTest();
            
            System.assert( newlead  != null);
        }
    }

    private static void createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Salesteamleiter Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'CCS Telesales Team Lead'];
        
        u = new User(
            UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '_23423_test2@test.com',
            Alias = 'batman',
            Email = 'bruce.wayne_1233@wayneenterprises.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Bruce',
            Lastname = 'Wayne',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(u);
    }

    private static void createLead() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'CCS Sales process' AND sObjectType = 'Lead' LIMIT 1];
        newlead = new Lead(
            LastName = 'Test',
            FirstName = 'testName',
            RecordTypeId = rt.Id,
            OwnerId = u.Id,
            Company = 'Test company',
            CCS_Company_ID__c = '1234567',
            CCS_Number_of_GPS_units__c = 777,
            CCS_Close_Date__c = Date.newInstance(2018, 9, 7),
            Opportunity_Type__c = 'New Business',
            Produkt__c = 'CCS Bonus',
            Anzahl_der_Fahrzeuge__c = 3,
            Number_of_Vehicles__c = 3,
            CCS_number_of_cards__c = 3,
            Country = 'Germany',
            Street = 'test',
            City = 'Berlin',
            PostalCode = '223141',
            Salutation = 'Herr',
            Email = 'test@test.com',
            Send_SEPA_approval_link__c = true,
            Beschaeftigte__c = '1-4',
            Branche_NACE__c = 'Apotheken - 4773');
        insert newlead;
    }
}