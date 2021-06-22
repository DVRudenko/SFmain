@isTest
private class TaskTriggerTest {
    @isTest
    private static void testStatusDateChange() {
        Task newTask = new Task(
                Subject = 'Call',
                Priority = 'Normal',
                Status = 'In Bearbeitung');
        insert newTask;

        newTask.Status = 'Completed';
        DateTime tempDate = DateTime.now();
        update newTask;

        Task testTask = [
                SELECT Last_Task_Status_Change__c
                FROM Task
                WHERE Id = :newTask.Id
        ];

        system.assertNotEquals(null, testTask.Last_Task_Status_Change__c);
    }


    @isTest
    private static void testSetPrimartContact() {
        Account newAccount = new Account(
                Name = 'Test',
                BillingCountry = 'Germany');
        insert newAccount;

        Contact contact = new Contact(
                Salutation = 'Mr.',
                LastName = 'test tt',
                Phone = '+491231231231');
        insert contact;

        Opportunity opp = new Opportunity(
                Name = 'test',
                AccountId = newAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today());
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opp.Id,
                IsPrimary = true);
        insert ocr;

        Task newTask = new Task(
                Subject = 'Call',
                Priority = 'Normal',
                Status = 'Completed',
                WhatId = opp.Id);
        insert newTask;
        Test.startTest();
        Test.stopTest();

        Task testTask = [
                SELECT WhoId
                FROM Task
                WHERE Id = :newTask.Id
        ];
        System.assertEquals(contact.Id, testTask.WhoId);
    }


    @isTest
    private static void testProvideAccessToDeleteTasks() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Inbound'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'Salesteam Outbound 2'];
        Integer rand = Math.round(Math.random() * 100000);
        User u = new User(
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                Username = rand + '@' + rand + 'test.com',
                Alias = 'so2',
                Email = 'sale.outb_' + rand + '@test.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(u);

        System.runAs(u) {
            Task newTask = new Task(
                    Subject = 'Call',
                    Priority = 'Normal',
                    Status = 'Completed',
                    WhoId = null,
                    WhatId = null);
            insert newTask;

            List<String> deleteErrorMessageList = new List<String>();
            try {
                Delete newTask;
            } catch (Exception e) {
                deleteErrorMessageList.add(e.getMessage());
            }

            Task testTask = [
                    SELECT WhatId
                    FROM Task
                    WHERE Id = :newTask.Id
            ];
            System.assertEquals(deleteErrorMessageList.size(), 1);
        }
    }


    @isTest
    private static void testAttachments() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Russian Sales Manager'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR Teamleader Telesales PSO 1'];
        Integer rand = Math.round(Math.random() * 100000);
        User u = new User(
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                Username = rand + '@' + rand + 'test.com',
                Alias = 'so2',
                Email = 'sale.outb_' + rand + '@test.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(u);

        System.runAs(u) {
            Task newTask = new Task(
                    Subject = 'Call',
                    Priority = 'Normal',
                    Status = 'Completed',
                    WhoId = null,
                    WhatId = null);
            insert newTask;

            Attachment newAttachment = new Attachment(name = 'Test1', ParentId = newTask.id, Body = Blob.valueOf('Test2'));
            insert newAttachment;

            Task testTask = [
                    SELECT Task.Attachments_Exist__c
                    FROM Task
                    WHERE Id = :newTask.Id
            ];
            System.assertEquals(testTask.Attachments_Exist__c, True);

            newAttachment.name = 'TestUpdate';
            update newAttachment;
            Task testTask1 = [
                    SELECT Task.Attachments_Exist__c
                    FROM Task
                    WHERE Id = :newTask.Id
            ];
            System.assertEquals(testTask1.Attachments_Exist__c, True);

            delete newAttachment;
            Task testTask2 = [
                    SELECT Task.Attachments_Exist__c
                    FROM Task
                    WHERE Id = :newTask.Id
            ];
            System.assertEquals(testTask2.Attachments_Exist__c, False);
        }
    }


    @isTest
    private static void testSetRecordType() {
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Russian Sales Manager'];
        UserRole ur = [SELECT Id FROM UserRole WHERE Name = 'PPR Teamleader Telesales PSO 1'];
        Integer rand = Math.round(Math.random() * 100000);
        User u = new User(
                UserRoleId = ur.Id,
                ProfileId = p.Id,
                Username = rand + '@' + rand + 'test.com',
                Alias = 'so2',
                Email = 'sale.outb_' + rand + '@test.com',
                EmailEncodingKey = 'UTF-8',
                Firstname = 'Bruce',
                Lastname = 'Wayne',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(u);

        System.runAs(u) {
            Task newTask = new Task(
                    Subject = 'Call',
                    Priority = 'Normal',
                    OwnerId = u.Id,
                    Status = 'In Bearbeitung');
            insert newTask;

            Task updatedTask = [
                    SELECT Id, RecordType.Name
                    FROM Task
                    WHERE Id = :newTask.Id
                    LIMIT 1
            ];
            System.assertEquals('Russian Sales', updatedTask.RecordType.Name);
        }
        Test.stopTest();
    }

    @isTest
    private static void testUpdateNumberOfOpenTasks() {

        Opportunity oppty = new Opportunity(
                Name = 'test',
                StageName = 'Prospecting',
                Number_of_open_tasks__c = 0,
                CloseDate = Date.today());
        insert oppty;

        Lead newLead = new Lead(
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
                Number_of_open_tasks__c = 0,
                LeadSource = 'Internet',
                Status = 'Contacted',
                Disable_for_KPI__c = FALSE
        );
        insert newLead;

        Task newTaskToOppty = new Task(
                Subject = 'Call',
                Priority = 'Normal',
                WhatId = oppty.Id,
                Status = 'In Bearbeitung');
        insert newTaskToOppty;

        Task newTaskToLead = new Task(
                Subject = 'Call',
                Priority = 'Normal',
                WhoId = newLead.Id,
                Status = 'Completed');
        insert newTaskToLead;

        User newUser = [SELECT Id FROM User WHERE Name = 'Integration Administrator' LIMIT 1];

        newTaskToOppty.OwnerId = newUser.Id;
        update newTaskToOppty;
        newTaskToLead.OwnerId = newUser.Id;
        update newTaskToLead;

        Opportunity opp = [SELECT Number_of_open_tasks__c, Open_Task__c FROM Opportunity WHERE Id = :oppty.Id LIMIT 1];
        System.assertEquals(1, opp.Number_of_open_tasks__c);
        System.assertEquals(false, opp.Open_Task__c);

        newTaskToLead.Status = 'In Bearbeitung';
        update newTaskToLead;
        newTaskToOppty.Status = 'Completed';
        update newTaskToOppty;

        Lead lead = [SELECT Number_of_open_tasks__c, Open_Task__c FROM Lead WHERE Id = :newLead.Id LIMIT 1];
        System.assertEquals(1, lead.Number_of_open_tasks__c);
        System.assertEquals(false, lead.Open_Task__c);

        delete newTaskToLead;
        delete newTaskToOppty;
    }

    @isTest
    private static void testsetFive9Phone() {
        Lead leadGermany = new Lead(
                Country = 'Slovakia',
                CountryCode = 'SK',
                Company = 'Company test',
                Salutation = 'Herr',
                FirstName = 'nameLead',
                LastName = 'familyLead',
                Phone = '3333333');
        insert leadGermany;

        Contact contactAustria = new Contact(
                Phone = '0451 - 5040367',
                MobilePhone = '01702153391',
                Fax = '282245167',
                MailingCountry = 'Slovakia',
                MailingCountryCode = 'SK',
                LastName = 'test',
                Salutation = 'Herr');
        insert contactAustria;

        Account accountPoland = new Account(
                Phone = '+48 22 0476 75 950',
                SM_mobile__c = '01702153391',
                Fax = '282245167',
                BillingCountry = 'Slovakia',
                BillingCountryCode = 'SK',
                Name = 'test');
        insert accountPoland;

        Account accountSlovakia = new Account(
                Name = 'test',
                GFN_Nr__c = '123',
                Type = 'Customer',
                Bundesland__c = 'Germany',
                BillingCountry = 'Slovakia',
                BillingCountryCode = 'SK',
                Beschaeftigte__c = '1-4',
                Strasse_E__c = 'test',
                Hausnummer_E__c = 'test',
                PLZ_E__c = 'test',
                Ort_E__c = 'tet',
                Land_E__c = 'DE',
                Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
                Strasse_und_Hausnummer__c = 'tes',
                PLZ_und_Ort__c = 'test',
                IBAN_des_Zahlungspflichtigen__c = 'tes',
                SWIFT_BIC__c = 'test',
                Land__c = 'test land',
                Gruende_fuer_Tankkarten__c = 'vereinfachte Abrechnung',
                Kraftstoffverbrauch_Liter_Monat__c = 2
        );
        insert accountSlovakia;

        Opportunity opportunitySlovakia = new Opportunity(
                AccountId = accountSlovakia.Id,
                Name = 'test opportunity',
                Starts_Status__c = '0. Request received',
                Starts_Schedule__c = Date.today().addDays(-1),
                Starts_Overdue_days__c = 0,
                Starts_Status_Delay__c = false,
                Anzahl_der_Karten__c = 123,
                Zahlungsart__c = 'Lastschrift',
                Name_of_the_payer_Account_holder__c = 'test payer',
                Angebotsdauer__c = 'test',
                Language_preference__c = 'Polish',
                Product__c = 'Home Station offer (v.1)',
                Home_Station__c = '123test',
                IBAN__c = '23424',
                SWIFT_BIC__c = '23423',
                Derzeitige_Zahlungsmethode__c = 'Barzahlung',
                Requested_monthly_Company_Credit_Spend__c = 12345,
                AGB_Datenschutzhinweise_Richtigkeit__c = true,
                Data_Protection_Act_1998__c = true,
                Umsatz__c = '123',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(-50),
                Bevollmaechtigung__c = true
        );
        insert opportunitySlovakia;

        List<Task> tasksToInsertList = new List<Task>();
        Task taskLeadSK = new Task(
                Subject = 'Call',
                NVMContactWorld__ContactWorld_Number__c = '0271 - 25093460',
                NVMContactWorld__Customer_Number__c = '',
                Priority = 'Normal',
                WhoId = leadGermany.Id,
                Status = 'In Bearbeitung');
        tasksToInsertList.add(taskLeadSK);

        Task taskContactSK = new Task(
                Subject = 'Call',
                NVMContactWorld__ContactWorld_Number__c = '0042127125093460',
                NVMContactWorld__Customer_Number__c = '4912345',
                Priority = 'Normal',
                WhoId = contactAustria.Id,
                Status = 'In Bearbeitung');
        tasksToInsertList.add(taskContactSK);

        Task taskAccountSK = new Task(
                Subject = 'Call',
                NVMContactWorld__ContactWorld_Number__c = '421(0)25093460',
                NVMContactWorld__Customer_Number__c = '123123123 test@test',
                Priority = 'Normal',
                WhatId = accountPoland.Id,
                Status = 'In Bearbeitung');
        tasksToInsertList.add(taskAccountSK);

        Task taskOpportunitySK = new Task(
                Subject = 'Call',
                NVMContactWorld__ContactWorld_Number__c = '+421(0)333333',
                NVMContactWorld__Customer_Number__c = '491  23 / 99',
                Priority = 'Normal',
                WhatId = opportunitySlovakia.Id,
                Status = 'In Bearbeitung');
        tasksToInsertList.add(taskOpportunitySK);

        insert tasksToInsertList;

        Set<Id> idsToTest = new Set<Id>();
        for (Task currentTask : tasksToInsertList) {
            idsToTest.add(currentTask.Id);
        }

        Map<Id, Task> leadsToTestMap = new Map<Id, Task>([
                SELECT NVMContactWorld__ContactWorld_Number__c, NVMContactWorld__Customer_Number__c
                FROM Task
                WHERE Id IN :idsToTest
                LIMIT 10000
        ]);

        // Germany lead
        System.assertEquals('+42127125093460', leadsToTestMap.get(taskLeadSK.Id).NVMContactWorld__ContactWorld_Number__c);
        System.assertEquals(null, leadsToTestMap.get(taskLeadSK.Id).NVMContactWorld__Customer_Number__c);

        // Germany contact
        System.assertEquals('+42127125093460', leadsToTestMap.get(taskContactSK.Id).NVMContactWorld__ContactWorld_Number__c);
        System.assertEquals('+4214912345', leadsToTestMap.get(taskContactSK.Id).NVMContactWorld__Customer_Number__c);

        // Germany account
        System.assertEquals('+42125093460', leadsToTestMap.get(taskAccountSK.Id).NVMContactWorld__ContactWorld_Number__c);
        System.assertEquals('+421123123123', leadsToTestMap.get(taskAccountSK.Id).NVMContactWorld__Customer_Number__c);

        // Germany opportunity
        System.assertEquals('+421333333', leadsToTestMap.get(taskOpportunitySK.Id).NVMContactWorld__ContactWorld_Number__c);
        System.assertEquals('+4214912399', leadsToTestMap.get(taskOpportunitySK.Id).NVMContactWorld__Customer_Number__c);
    }

    @isTest
    private static void testSetDueDate() {
        Task newTask = new Task(
            Subject = 'Call',
            Priority = 'Normal',
            Due_Date_Today__c = true,
            Status = 'In Bearbeitung'        
        );
        insert newTask;

        Date today = Date.today();

        Task testTask = [
            SELECT ActivityDate
            FROM Task
            WHERE Id = :newTask.Id
        ];

        system.assertEquals(today, testTask.ActivityDate);
    }
}