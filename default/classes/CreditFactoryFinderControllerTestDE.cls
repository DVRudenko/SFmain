@isTest
private class CreditFactoryFinderControllerTestDE {
    public static CreditFactoryFinderController controller;   
    
    
    /*******************************************************************************
    *  Name            : createDataForAllTests()
    *  Summary         : Create data for all test methods
    *  CreatedDate     : 11/11/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @testSetup
    static void createDataForAllTests() {
        Credit_Factory_User_Profile__c cfUserProfile = CreditFactoryUtils.createCreditFactoryUserProfile();
        insert cfUserProfile;
        
        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = CreditFactoryUtils.createCreditFactorySoqlFieldsList();
        creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
            Name = 'CF_Orders__c', Field_Name__c = 'CF_Orders__c'));
        insert creditFactorySoqlFieldsList;
    }

    
    /*******************************************************************************
	*  Summary         : Leave opportunity id as null in vf page.
	*  CreatedDate     : 04/03/2020
	*  Parameters      : -
	*  Returns         : -
	******************************************************************************/
	@isTest
    static void testInvalidOpportunityId() {
        Test.startTest();
        	controller = new CreditFactoryFinderController();
        	controller.init();
        Test.stopTest();

        System.assertEquals('Invalid record id.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Leave country field as empty.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testInvalidCountry() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        account.BillingCountry = '';
        account.BillingCountryCode = '';
        update account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Test.startTest();
        controller = new CreditFactoryFinderController();
        controller.init();
        Test.stopTest();

        System.assertEquals('Please add Billing Country to Account.', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Don't create Credit System custom setting.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testInvalidCreditSystem() {
    	Account account = CreditFactoryUtils.createAccountDE();
    	insert account;

    	Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
    	insert opportunity;

    	ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Test.startTest();
        	controller = new CreditFactoryFinderController();
        	controller.init();
        Test.stopTest();

    	System.assertEquals('Select Credit System Settings failed. Please check Billing Country or contact your administrator.', ApexPages.getMessages().get(0).getSummary());
    }

    
    /*******************************************************************************
    *  Summary         : Create Account mapping not with "Schufa" name.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest
    static void testInvalidAccountMappingName() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test');
        insert creditFactoryAccount;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Account mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Create Opportunity mapping not with "Schufa" name.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testInvalidOpportunityMappingName() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Schufa');
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test');
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity mapping select error. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Summary         : Leave empty Account mapping field.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    static void testInvalidAccountMapping() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        creditFactoryAccount.Company_Form__c = '';
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('All fields in Account mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Summary         : Leave empty Opportunity mapping field.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : void
    *****************************************************************************/
    @isTest
    static void testInvalidOpportunityMapping() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        creditFactoryOpportunity.Credit_System_Limit__c = '';
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('All fields in Opportunity mapping should not be null. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /******************************************************************************
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest 
    static void testProfileValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;
        
        List<Credit_Factory_User_Profile__c> cfUsersProfilesList = [SELECT Id FROM Credit_Factory_User_Profile__c];
        delete cfUsersProfilesList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Your profile doesn\'t have access to Credit Factory.', ApexPages.getMessages().get(0).getSummary());
    }


    /******************************************************************************
    *  Summary         : Try to launch Credit Factory for Closed Opportunity.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest 
    static void testClosedOpportunity() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.StageName = 'Closed Won';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Opportunity was already closed.', ApexPages.getMessages().get(0).getSummary());
    }


    /*****************************************************************************
    *  Summary         : Create Opportunity (or Account) that stores in Black List
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    ****************************************************************************/
    @isTest
    static void testBlackListValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        account.Name = 'Test Black List';
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = account.Name,
            Customer_Id__c = 'DE'
        );
        
        insert blackList;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages().get(0).getSummary().contains('Company found in black list. Please refer to credit.'));
    }


    /*******************************************************************************
    *  Summary         : Fill Processed by field.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testProcessedOpportunityValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.bearbeitet_von__c = 'test';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Your Opportunity has already received a Credit Decision or is in the ongoing Manual Review with the Credit Team.', ApexPages.getMessages().get(0).getSummary());
    }
    
    
    /*******************************************************************************
    *  Summary         : Test Desired Payment Details validation
    *  CreatedDate     : 04/06/2020 by Anton Buzak
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    static void testDesiredPaymentDetailsValidation() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunity.Zahlungsziel_2__c = '10';
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Desired Billing Period and Desired Payment terms are not available. Available options are: 7+7, 15+7, 30+7', ApexPages.getMessages().get(0).getSummary());
    }


    /*******************************************************************************
    *  Summary         : Test duplicates check in opportunities, accounts and contacts.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    @isTest
    public static void testDuplicatesCheck() {
        List<Account> accountsList = new List<Account>();
        Account account = CreditFactoryUtils.createAccountDE();
        accountsList.add(account);
        Account duplicateAccount = CreditFactoryUtils.createAccountDE();
        duplicateAccount.Steuernummer__c = '123123123123';
        accountsList.add(duplicateAccount);
        insert accountsList;

        List<Opportunity> opportunitiesList = new List<Opportunity>();
        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        opportunitiesList.add(opportunity);
        Opportunity duplicateOpportunity = CreditFactoryUtils.createOpportunityDE(duplicateAccount.Id);
        opportunitiesList.add(duplicateOpportunity);
        insert opportunitiesList;

        List<Contact> contactsList = new List<Contact>();
        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        contactsList.add(contact);
        Contact duplicateContact = CreditFactoryUtils.createContactDE(duplicateAccount.Id);
        contactsList.add(duplicateContact);
        insert contactsList;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        OpportunityContactRole opportunityContactRole = CreditFactoryUtils.createOpportunityContactRoleDE(contact.Id, opportunity.Id);
        insert opportunityContactRole;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Accounts found'));
        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Opportunities found'));
        System.assertEquals(true, String.valueOf(ApexPages.getMessages().get(0)).contains('Duplicate Contacts found'));
    }


    /******************************************************************************
    *  Summary         : Test unsuccessful company search.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : -
    *****************************************************************************/
    @isTest
    static void testInvalidCompanySearch() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        creditSystem.Endpoint__c = null;
        insert creditSystem;

        Test.startTest();
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        System.assertEquals('Search company failed. ' + CreditFactoryUtilities.CONTACT_ADMIN, ApexPages.getMessages().get(0).getSummary());   
    }


    /*******************************************************************************
    *  Summary         : Check success search company
    *  CreatedDate     : 04/03/2020
    *  Parameters      : - 
    *  Returns         : -
    ******************************************************************************/
    @isTest 
    static void testValidSearchCompany() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;

        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;

        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');

        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;

        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;

        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', authMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"totalHits": 164,"companies": [{"companyId": 8688677,"companyName": "BMW Automobilclub Kassel","foundationDate": "19.03.93","formOfOrganisation": "EV","zipCode": "34117","city": "Kassel","branchCode": "9499","registerCourt": "Kassel","traderegisterNumber": "VR 2424","alreadyOnboarded": false,"onboardingDate": ""}]}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/search/full/detail', searchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryFinderController();
            controller.init();
            controller.selectCompanyForReport();
            controller.backToOpporutnity();
            controller.setInvalidSearch();
        Test.stopTest();
    }
    
    
    
    /*******************************************************************************
    *  Summary         : test ordering report in case of no matches for the company
    *  CreatedDate     : 16/03/2020
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    @isTest 
    public static void testOrder() {
        Account account = CreditFactoryUtils.createAccountDE();
        insert account;
        
        Opportunity opportunity = CreditFactoryUtils.createOpportunityDE(account.Id);
        insert opportunity;
        
        Contact contact = CreditFactoryUtils.createContactDE(account.Id);
        insert contact;
        
        OpportunityContactRole role = CreditFactoryUtils.createOpportunityContactRoleDE(contact.Id, opportunity.Id);
        insert role;
        
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        ApexPages.currentPage().getParameters().put('companyIndex', '0');
        
        Credit_Factory_Account__c creditFactoryAccount = CreditFactoryUtils.createSchufaAccountMapping();
        insert creditFactoryAccount;
        
        Credit_Factory_Opportunity__c creditFactoryOpportunity = CreditFactoryUtils.createSchufaOpportunityMapping();
        insert creditFactoryOpportunity;
        
        CreditSystem__c creditSystem = CreditFactoryUtils.createSchufaCreditSystem();
        insert creditSystem;
        
        CF_Order_Notifications__c notification = CreditFactoryUtils.createOrderNotificationDE();
        insert notification;

        Test.startTest();
            Map<String, HttpCalloutMock> mocksMap = new Map<String,HttpCalloutMock>();
            SingleRequestMock authMock = new SingleRequestMock(200, 'Complete', '{"accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkUjdHLUpaMVF4Vmd2WmVYYUprU1J5Y0lBYXo0RG9MelpCdFJWLTNleG9jIn0.eyJqdGkiOiJlYjNmNDBlNi1kNzBmLTQ1YmMtYTU1YS02MjcwYTE0NjE4OGUiLCJleHAiOjE1ODMzMzg2NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiYWNjb3VudCIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImZsZWV0Y29yX2V1IiwiYXV0aF90aW1lIjowLCJzZXNzaW9uX3N0YXRlIjoiNGU1Y2E0MmEtMzA4Mi00MmQwLWFlM2ItYTNiNzRiMjE5MTk5IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudEhvc3QiOiIxMC40Mi42LjIxNyIsImNsaWVudElkIjoiZmxlZXRjb3JfZXUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1mbGVldGNvcl9ldSIsImNsaWVudEFkZHJlc3MiOiIxMC40Mi42LjIxNyIsImVtYWlsIjoic2VydmljZS1hY2NvdW50LWZsZWV0Y29yX2V1QHBsYWNlaG9sZGVyLm9yZyJ9.NNjTXdtiIiTEjpV2Z7SE-PzpePQPj3TzT7zaC68Fr-PUvMqPm8ia24-VqIx1w7CgNFvfTxT4OJC8zItattObtgY-QoP2pOM7kYBn8qTC4xLbKQbbe7HFfIrcZWP1KSpHO_1C9uJyYSn216cIKzAxke0muqfNi1A4xklp0ly105wBe6rj9JzDvGfhQoYndPXE634AJkcYKPeNp14RFQhEGIcMmFx9fl5vsfm2u6EU4LenJrBsTtBp_fX4gkVOEcCteqefhkEEzP4U22_-4UTNmVnkEFkItQ6ROQIyk2p1PaAn2i-H8ezr7SpGKKxLrRK5nna7F4PtR5a3rbbxWL8J4A","expiresIn": 18000,"refreshExpiresIn": 1800,"refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxNzEyZmJmMi0zOTVjLTRiMTktYTQzYS0xZGQ4NDEwMWQwMDcifQ.eyJqdGkiOiJlNWI4NjFmOS0wYmM1LTQ3NDktYjg1Ny0zNTRiZjhmMmI0YmMiLCJleHAiOjE1ODMzMjI0NTIsIm5iZiI6MCwiaWF0IjoxNTgzMzIwNjUyLCJpc3MiOiJodHRwczovL3Nzby50ZXN0LmZpbm8uY2xvdWQvYXV0aC9yZWFsbXMva3ljbm93IiwiYXVkIjoiaHR0cHM6Ly9zc28udGVzdC5maW5vLmNsb3VkL2F1dGgvcmVhbG1zL2t5Y25vdyIsInN1YiI6IjU5ZGRlOGYyLWQ5OTEtNDNkNi05NGEyLTg3OTg5MWVhMGRlOSIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJmbGVldGNvcl9ldSIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjRlNWNhNDJhLTMwODItNDJkMC1hZTNiLWEzYjc0YjIxOTE5OSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiZmxlZXRjb3JfZXUiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSJ9.vanyXkYPjp5MghPdGNHSrpodduMjfgfRGmU4LKmzXQA","tokenType": "bearer","notBeforePolicy": 1570625734,"sessionState": "4e5ca42a-3082-42d0-ae3b-a3b74b219199","scope": "email profile"}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/auth', authMock);
            SingleRequestMock searchMock = new SingleRequestMock(200, 'Complete', '{"totalHits": 0}', null);
            mocksMap.put('https://kycnow.test.fino.cloud/api/v1/company/search/full/detail', searchMock);
            HttpCalloutMock multiCalloutMock = new MultiRequestMock(mocksMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
            controller = new CreditFactoryFinderController();
            controller.init();
        Test.stopTest();

        List<Opportunity> opportunitiesList = [
                SELECT CF_Order_Reference_Number__c, CF_Stage__c
                FROM Opportunity
                WHERE Id = :opportunity.Id];
        
        System.assertEquals('Pending Credit Report - Order was sent', opportunitiesList.get(0).CF_Stage__c);
    }
}