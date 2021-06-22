@IsTest
private class VATRecoveryEmailTest {
    @IsTest
    static void testing() {
    
    String userId = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC' LIMIT 1][0].Id;
    
    String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'VAT_Recovery_activation' LIMIT 1][0].Id;
    
    String AccountRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde' LIMIT 1][0].Id;
    String AccountRecordTypeId2 = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'CCS' LIMIT 1][0].Id;
    //String AccountRecordTypeId3 = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Endkunde_PL_and_HU' LIMIT 1][0].Id;
    
    String OpportunityRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell' LIMIT 1][0].Id;
    String OpportunityRecordTypeId2 = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Euroshell_Starts' LIMIT 1][0].Id;
    
                VAT_Recovery_Emails__c setting = new VAT_Recovery_Emails__c();
                setting.Name = 'Austria';
                setting.Email__c = 'info@intercodec.cz';
                insert setting;
                
                VAT_Recovery_Emails__c setting2 = new VAT_Recovery_Emails__c();
                setting2.Name = 'Poland';
                setting2.Email__c = 'info@intercodec.cz';
                insert setting2;
                
                VAT_Recovery_Emails__c setting3 = new VAT_Recovery_Emails__c();
                setting3.Name = 'Germany';
                setting3.Email__c = 'info@intercodec.cz';
                insert setting3;
                
                VAT_Recovery_Emails__c setting4 = new VAT_Recovery_Emails__c();
                setting4.Name = 'Netherlands';
                setting4.Email__c = 'info@intercodec.cz';
                insert setting4;
                
                VAT_Recovery_Emails__c setting5 = new VAT_Recovery_Emails__c();
                setting5.Name = 'Belgium-NL';
                setting5.Email__c = 'info@intercodec.cz';
                insert setting5;
                
                VAT_Recovery_Emails__c setting6 = new VAT_Recovery_Emails__c();
                setting6.Name = 'Belgium-FR';
                setting6.Email__c = 'info@intercodec.cz';
                insert setting6;
                
                VAT_Recovery_Emails__c setting7 = new VAT_Recovery_Emails__c();
                setting7.Name = 'France';
                setting7.Email__c = 'info@intercodec.cz';
                insert setting7;
                
                VAT_Recovery_Emails__c setting8 = new VAT_Recovery_Emails__c();
                setting8.Name = 'Luxembourg';
                setting8.Email__c = 'info@intercodec.cz';
                insert setting8;
                
                VAT_Recovery_Emails__c setting9 = new VAT_Recovery_Emails__c();
                setting9.Name = 'Hungary';
                setting9.Email__c = 'info@intercodec.cz';
                insert setting9;
                
                VAT_Recovery_Emails__c setting10 = new VAT_Recovery_Emails__c();
                setting10.Name = 'Czech Republic';
                setting10.Email__c = 'info@intercodec.cz';
                insert setting10;
                
                VAT_Recovery_Emails__c setting11 = new VAT_Recovery_Emails__c();
                setting11.Name = 'Slovakia';
                setting11.Email__c = 'info@intercodec.cz';
                insert setting11;
    
                Account a = new Account(
                Name = 'test',
                RecordTypeId = AccountRecordTypeId,
                OwnerId = userId,
                BillingCountry = 'Austria',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69');
                insert a;
                
                Account a2 = new Account(
                Name = 'test',
                RecordTypeId = AccountRecordTypeId,
                OwnerId = userId,
                BillingCountry = 'Germany',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69',
                ParentId = a.Id);
                insert a2;
                
                Account a3 = new Account(
                Name = 'test',
                RecordTypeId = AccountRecordTypeId,
                OwnerId = userId,
                BillingCountry = 'France',
                BillingCountryCode = 'FR',
                BillingCity = 'Paris',
                BillingStreet = 'Rue 69',
                ParentId = a.Id);
                insert a3;
                
                Account a4 = new Account(
                Name = 'test',
                RecordTypeId = AccountRecordTypeId2,
                OwnerId = userId,
                BillingCountry = 'Czech Republic',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69',
                ParentId = a.Id);
                insert a4;
                
                Account a5 = new Account(
                Name = 'test',
                RecordTypeId = AccountRecordTypeId,
                OwnerId = userId,
                BillingCountry = 'Hungary',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69',
                ParentId = a.Id);
                insert a5;
                
                Account account = new Account(
                Name = 'INTERCODEC4',
                RecordTypeId = AccountRecordTypeId,
                OwnerId = userId,
                BillingStreet = 'TESTOVACI 1',
                BillingCity = 'WARSAW',
                BillingCountry = 'Poland',
                ParentId = a.Id);
                insert account;

        Contact c = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = a.Id,
                Email = 'test@test.com');
        insert c;
        
        Contact c2 = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = account.Id,
                Email = 'test@test.com');
        insert c2;
        
        Contact c3 = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = a2.Id,
                Email = 'test@test.com');
        insert c3;
        
        Contact c4 = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = a3.Id,
                Email = 'test@test.com');
        insert c4;
        
        Contact c5 = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = a4.Id,
                Email = 'test@test.com');
        insert c5;
        
        Contact c6 = new Contact(
                Salutation = 'Herr',
                LastName = 'test',
                AccountId = a5.Id,
                Email = 'test@test.com');
        insert c6;

        Opportunity o = new Opportunity(
                Name = 'test',
                RecordTypeId = OpportunityRecordTypeId,
                AccountId = a.id,
                Primary_Contact__c = c.Id,
                CloseDate = System.today(),
                StageName = 'Closed Won',
                Agree_to_VAT_Recovery_TC__c = True,
                Type = 'New GFN',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o;
        
        Opportunity o2 = new Opportunity(
                Name = 'test',
                RecordTypeId = OpportunityRecordTypeId,
                AccountId = account.id,
                Primary_Contact__c = c2.Id,
                CloseDate = System.today(),
                StageName = 'Closed Won',
                Agree_to_VAT_Recovery_TC__c = True,
                Type = 'New GFN',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o2;
        
        Opportunity o3 = new Opportunity(
                Name = 'test',
                RecordTypeId = OpportunityRecordTypeId2,
                AccountId = a2.id,
                Primary_Contact__c = c3.Id,
                CloseDate = System.today(),
                StageName = 'Closed Won',
                Agree_to_VAT_Recovery_TC__c = True,
                Type = 'New GFN',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o3;
        
        Opportunity o4 = new Opportunity(
                Name = 'test',
                RecordTypeId = OpportunityRecordTypeId2,
                AccountId = a3.id,
                Primary_Contact__c = c4.Id,
                CloseDate = System.today(),
                StageName = 'Closed Won',
                Agree_to_VAT_Recovery_TC__c = True,
                Type = 'New GFN',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o4;
        
        Opportunity o5 = new Opportunity(
                Name = 'test',
                RecordTypeId = OpportunityRecordTypeId2,
                AccountId = a4.id,
                Primary_Contact__c = c5.Id,
                CloseDate = System.today(),
                StageName = 'Closed Won',
                Agree_to_VAT_Recovery_TC__c = True,
                Type = 'New GFN',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o5;
        
        Opportunity o6 = new Opportunity(
                Name = 'test',
                RecordTypeId = OpportunityRecordTypeId2,
                AccountId = a5.id,
                Primary_Contact__c = c6.Id,
                CloseDate = System.today(),
                StageName = 'Closed Won',
                Agree_to_VAT_Recovery_TC__c = True,
                Type = 'New GFN',
                Number_of_GPS_units__c = 3,
                Pricing_Approval_Status__c = 'Not required');
        insert o6;

        test.startTest();
        
        List<id> listOfOpportunities = new List<Id>();
        listOfOpportunities.add(o.Id);
        listOfOpportunities.add(o2.Id);
        listOfOpportunities.add(o3.Id);
        listOfOpportunities.add(o4.Id);
        listOfOpportunities.add(o5.Id);
        listOfOpportunities.add(o6.Id);
        
        VATRecoveryEmail VAT = new VATRecoveryEmail();
        
        VAT.sendVAT(listOfOpportunities);
        
        test.stopTest();
    }
}