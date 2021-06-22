@isTest
private class PaymentTransactionHandlerTest {

    static testMethod void testmethod1(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Enable_authorization_non_granted_check__c = true,
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Poland');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.Status__c = '0';
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];
        system.assertEquals(list1.size(),0);
    }


    static testMethod void testmethod2(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Enable_authorization_non_granted_check__c = true,
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '9';
        paymentTransaction.Authorized__c = TRUE;
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];

        List<Opportunity> list2 = [
                SELECT id, stagename, garantie_other__c
                FROM Opportunity
                WHERE id=:opportunity.id
                LIMIT 1
        ];

        system.assertEquals(list1.size(),1);
        system.assertEquals(list2.get(0).Stagename,'Closed Won');
        system.assertEquals(list2.get(0).garantie_other__c,paymentTransaction.Amount__c);
    }

    static testMethod void testmethod3(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Enable_authorization_non_granted_check__c = true,
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Poland');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '1';
        paymentTransaction.Authorized__c = TRUE;
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];
        system.assertEquals(list1.size(),1);
    }


    static testMethod void testmethod4(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Enable_authorization_non_granted_check__c = true,
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Poland');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '2';
        paymentTransaction.Authorized__c = TRUE;
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];
        system.assertEquals(list1.size(),1);
    }


    static testMethod void testmethod5(){
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Germany',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Enable_authorization_non_granted_check__c = true,
            Set_GFN_Status__c = true
        );
        insert e2eFormGeneralSettings;
        Account account = new Account(Name = 'test1', BillingPostalCode = '1231', BillingCountry = 'Poland');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test1', StageName = 'Qualified Lead', CloseDate = date.today(), Accountid = account.id,
                Security_Amount_To_Pay__c=10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.id;
        insert paymentTransaction;

        paymentTransaction.status__c = '12';
        paymentTransaction.Authorized__c = TRUE;
        update paymentTransaction;

        List<Payment_transaction__c> list1 = [
                SELECT id
                FROM Payment_Transaction__c
                WHERE id = :paymentTransaction.id
                AND Authorized__c = TRUE
        ];
        system.assertEquals(list1.size(),1);
    }


    static testMethod void payUTestMethod() {
        List<SObject> e2eSettingsToInsertList = new List<SObject>();
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
            Name = 'Poland',
            Test_mode__c = false,
            Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
            Enable_authorization_non_granted_check__c = true,
            Set_GFN_Status__c = true
        );
        e2eSettingsToInsertList.add(e2eFormGeneralSettings);

        GFNI_General_Settings__c gfniGeneralSettings = new GFNI_General_Settings__c();
        gfniGeneralSettings.Name = 'PL';
        gfniGeneralSettings.Application_Status__c = '/applicationstatus';
        gfniGeneralSettings.Create_Customer_and_Cards__c = '/customer';
        gfniGeneralSettings.Get_Customer_Id__c = '/customerId';
        gfniGeneralSettings.IsForRobot__c = true;
        gfniGeneralSettings.Number_Of_Send_Tries__c = 3;
        gfniGeneralSettings.Prod_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        gfniGeneralSettings.Test_Endpoint__c = 'https://api-fleetcor-eu.apiconnect.ibmcloud.com/fleetcor-eu/sb';
        gfniGeneralSettings.x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        gfniGeneralSettings.x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        gfniGeneralSettings.Support_email__c = 'test@email.com';
        gfniGeneralSettings.Test_support_email__c = 'test@test.com';
        gfniGeneralSettings.test_x_ibm_client_id__c = '49a8caea-2a51-4172-b387-c102be154f6f';
        gfniGeneralSettings.test_x_ibm_client_secret__c = 'eB8xT3aH6yY3rL4oO8fQ2sG2aJ5pL8rS4tD6kB0hU4kM4pS5fE';
        gfniGeneralSettings.Test_mode__c = true;
        e2eSettingsToInsertList.add(gfniGeneralSettings);

        Account_GFN_Report_Email_Params__c gfnReport = new Account_GFN_Report_Email_Params__c(
                Attach_format__c = '.xls',
                Email__c = 'fleetcor@enway.co',
                Email_body__c = 'Attached file is generated using Salesforce for a robot processing',
                Name = 'Excel'
        );
        e2eSettingsToInsertList.add(gfnReport);

        E2E_PayU_Settings__c e2ePayUSettings = new E2E_PayU_Settings__c(
            Name = 'Poland',
            IsActive__c = true
        );
        e2eSettingsToInsertList.add(e2ePayUSettings);
        insert e2eSettingsToInsertList;
        Account account = new Account(Name = 'payUTest', BillingPostalCode = '1231', BillingCountry = 'Poland');
        insert account;
        Opportunity opportunity = new Opportunity(
            Name = 'payUTest',
            StageName = 'Prospecting',
            CloseDate = date.today(),
            Accountid = account.Id,
            Security_Amount_To_Pay__c = 10);
        insert opportunity;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'PL';
        paymentTransaction.OpportunityId__c = opportunity.Id;
        insert paymentTransaction;

        paymentTransaction.Status__c = 'COMPLETED';
        update paymentTransaction;

        List<Opportunity> oppList = [SELECT Garantie_other__c, E2E_payment_status__c, StageName FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals(10, oppList.get(0).Garantie_other__c);
        System.assertEquals('ACCEPT', oppList.get(0).E2E_payment_status__c);
    }


    static testMethod void ete20PayUTest() {
        List<SObject> e2eSettingsToInsertList = new List<SObject>();
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
                Name = 'Poland',
                Test_mode__c = false,
                Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Enable_authorization_non_granted_check__c = true,
                Set_GFN_Status__c = true
        );
        e2eSettingsToInsertList.add(e2eFormGeneralSettings);

        E2E_PayU_Settings__c e2ePayUSettings = new E2E_PayU_Settings__c(
                Name = 'Poland',
                IsActive__c = true
        );
        e2eSettingsToInsertList.add(e2ePayUSettings);
        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormPL',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        e2eSettingsToInsertList.add(e2eKeysApi);
        insert e2eSettingsToInsertList;

        Account account = new Account(Name = 'payUTest', BillingPostalCode = '1231', BillingCountry = 'Poland');
        insert account;

        String recordTypeId = Schema.SObjectType.E2E_Data_Object__c.getRecordTypeInfosByName().get('Poland').getRecordTypeId();
        E2E_Data_Object__c dataObject = new E2E_Data_Object__c(
            RecordTypeId = recordTypeId,
            Name = 'Test Company',
            Selected_Company_Name__c = 'Test Company',
            Salutation__c = 'Mr.',
            First_Name__c = 'John',
            Last_Name__c = 'Johnson',
            Email__c = 'test@test.com',
            Phone__c = '+48 777-777-777',
            Country_Code__c = 'pl',
            Security_Amount_To_Pay__c = 10);
        insert dataObject;

        Contact contact = new Contact(
                AccountId = account.Id,
                Salutation = dataObject.Salutation__c,
                FirstName = dataObject.First_Name__c,
                LastName = dataObject.Last_Name__c,
                E2E__c = true,
                Email = dataObject.Email__c,
                Phone = dataObject.Phone__c
        );
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test Company',
                E2E_Data_Object__c = dataObject.Id,
                Security_To_Pay__c = 'Kaution',
                Security_Amount_To_Pay__c = 10,
                StageName = 'Prospecting',
                CloseDate = date.today(),
                Accountid = account.Id);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                IsPrimary = true,
                OpportunityId = opportunity.Id,
                ContactId = contact.Id
        );
        insert ocr;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'PL';
        paymentTransaction.OpportunityId__c = opportunity.Id;
        insert paymentTransaction;

        Test.startTest();
            paymentTransaction.Status__c = 'COMPLETED';
            update paymentTransaction;
        Test.stopTest();

        List<Opportunity> oppList = [SELECT Garantie_other__c, E2E_payment_status__c, StageName FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals(10, oppList.get(0).Garantie_other__c);
        System.assertEquals('ACCEPT', oppList.get(0).E2E_payment_status__c);
        System.assertEquals('Closed Won', oppList.get(0).StageName);
    }


    static testMethod void ete20PayuInvalidCaseTest() {
        List<SObject> e2eSettingsToInsertList = new List<SObject>();
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
                Name = 'Poland',
                Test_mode__c = false,
                Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Enable_authorization_non_granted_check__c = true,
                Set_GFN_Status__c = true
        );
        e2eSettingsToInsertList.add(e2eFormGeneralSettings);

        E2E_PayU_Settings__c e2ePayUSettings = new E2E_PayU_Settings__c(
                Name = 'Poland',
                IsActive__c = true
        );
        e2eSettingsToInsertList.add(e2ePayUSettings);
        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EFormPL',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        e2eSettingsToInsertList.add(e2eKeysApi);
        insert e2eSettingsToInsertList;

        Account account = new Account(Name = 'payUTest', BillingPostalCode = '1231', BillingCountry = 'Poland');
        insert account;

        String recordTypeId = Schema.SObjectType.E2E_Data_Object__c.getRecordTypeInfosByName().get('Poland').getRecordTypeId();
        E2E_Data_Object__c dataObject = new E2E_Data_Object__c(
                RecordTypeId = recordTypeId,
                Name = 'Test Company',
                Selected_Company_Name__c = 'Test Company',
                StageName__c = 'Prospecting',
                Salutation__c = 'Mr.',
                First_Name__c = 'John',
                Last_Name__c = 'Johnson',
                Email__c = 'test@test.com',
                Phone__c = '+48 777-777-777',
                Country_Code__c = 'pl',
                Security_Amount_To_Pay__c = 10);
        insert dataObject;

        Contact contact = new Contact(
                AccountId = account.Id,
                Salutation = dataObject.Salutation__c,
                FirstName = dataObject.First_Name__c,
                LastName = dataObject.Last_Name__c,
                E2E__c = true,
                Email = dataObject.Email__c,
                Phone = dataObject.Phone__c
        );
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test Company',
                E2E_Data_Object__c = dataObject.Id,
                Security_To_Pay__c = 'Kaution',
                Security_Amount_To_Pay__c = 10,
                StageName = 'Prospecting',
                CloseDate = date.today(),
                Accountid = account.Id);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                IsPrimary = true,
                OpportunityId = opportunity.Id,
                ContactId = contact.Id
        );
        insert ocr;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'PL';
        paymentTransaction.OpportunityId__c = opportunity.Id;
        insert paymentTransaction;

        Test.startTest();
        paymentTransaction.Status__c = 'REJECTED';
        update paymentTransaction;
        Test.stopTest();

        List<Opportunity> oppList = [SELECT Garantie_other__c, E2E_payment_status__c, StageName FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertNotEquals(10, oppList.get(0).Garantie_other__c);
        System.assertEquals('REJECTED', oppList.get(0).E2E_payment_status__c);
        System.assertEquals('Prospecting', oppList.get(0).StageName);
    }


    static testMethod void ete20IngenicoTest() {
        List<SObject> e2eSettingsToInsertList = new List<SObject>();
        E2E_Form_General_Settings__c e2eFormGeneralSettings = new E2E_Form_General_Settings__c(
                Name = 'Germany',
                Test_mode__c = false,
                Payment_URL__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Files_Generator_Url__c = 'https://e2e-e2efleetcor.cs89.force.com',
                Enable_authorization_non_granted_check__c = true,
                Set_GFN_Status__c = true
        );
        e2eSettingsToInsertList.add(e2eFormGeneralSettings);

        E2EKeysAPI__c e2eKeysApi = new E2EKeysAPI__c(
                Name = 'E2EForm',
                AES256_Key__c = 'F1kCSPMj49W2arKn9Ut0DmywkswU6E1Q/wlyutztVww=',
                paymentTransactionURL__c = 'https://ogone.test.v-psp.com/ncol/test//orderstandard_utf8.asp',
                PSPID__c = 'fleetcorTEST',
                SHA_KeyIn__c = 'FleetcorTest!12@',
                SHA_KeyOut__c = 'IngenFleetTest1!'
        );
        e2eSettingsToInsertList.add(e2eKeysApi);
        insert e2eSettingsToInsertList;

        Account account = new Account(Name = 'IngenicoTest', BillingPostalCode = '1231', BillingCountry = 'Germany');
        insert account;

        String recordTypeId = Schema.SObjectType.E2E_Data_Object__c.getRecordTypeInfosByName().get('Germany').getRecordTypeId();
        E2E_Data_Object__c dataObject = new E2E_Data_Object__c(
                RecordTypeId = recordTypeId,
                Name = 'Test Company',
                Selected_Company_Name__c = 'Test Company',
                Salutation__c = 'Mr.',
                First_Name__c = 'John',
                Last_Name__c = 'Johnson',
                Email__c = 'test@test.com',
                Phone__c = '+48 777-777-777',
                Country_Code__c = 'de',
                Security_Amount_To_Pay__c = 10);
        insert dataObject;

        Contact contact = new Contact(
                AccountId = account.Id,
                Salutation = dataObject.Salutation__c,
                FirstName = dataObject.First_Name__c,
                LastName = dataObject.Last_Name__c,
                E2E__c = true,
                Email = dataObject.Email__c,
                Phone = dataObject.Phone__c
        );
        insert contact;

        Opportunity opportunity = new Opportunity(
                Name = 'Test Company',
                E2E_Data_Object__c = dataObject.Id,
                Security_To_Pay__c = 'Kaution',
                Security_Amount_To_Pay__c = 10,
                StageName = 'Prospecting',
                CloseDate = date.today(),
                Accountid = account.Id);
        insert opportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(
                IsPrimary = true,
                OpportunityId = opportunity.Id,
                ContactId = contact.Id
        );
        insert ocr;

        Payment_Transaction__c paymentTransaction = new Payment_Transaction__c();
        paymentTransaction.Amount__c = 10;
        paymentTransaction.currency__c = 'EUR';
        paymentTransaction.OpportunityId__c = opportunity.Id;
        insert paymentTransaction;

        Test.startTest();
        paymentTransaction.Status__c = '9';
        update paymentTransaction;
        Test.stopTest();

        List<Opportunity> oppList = [SELECT Garantie_other__c, E2E_payment_status__c, StageName FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals(10, oppList.get(0).Garantie_other__c);
        System.assertEquals('ACCEPT', oppList.get(0).E2E_payment_status__c);
        System.assertEquals('Closed Won', oppList.get(0).StageName);
    }
}