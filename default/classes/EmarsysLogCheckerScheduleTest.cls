@isTest
private class EmarsysLogCheckerScheduleTest {
    private static void createDataDE() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;

        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        List<Lead> leadsToInsertList = new List<Lead>();
        Lead facebookDELead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookDELead);

        Lead inboundCallDELead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallDELead);

        Lead inboundEmailDELead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailDELead);

        Lead otherChannelDELead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelDELead);

        // Leads with wrong emarsys
        // Germany
        Lead facebookDELead1 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookDELead1);

        Lead inboundCallDELead1 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallDELead1);

        Lead inboundEmailDELead1 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailDELead1);

        Lead otherChannelDELead1 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Germany',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelDELead1);

        List<Emarsys_Log__c> emarsysLogsList = new List<Emarsys_Log__c>();
        // Germany logs
        Emarsys_Log__c facebookDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = facebookDELead1.Id);
        emarsysLogsList.add(facebookDELog);

        Emarsys_Log__c inboundCallDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = inboundCallDELead1.Id);
        emarsysLogsList.add(inboundCallDELog);

        Emarsys_Log__c inboundEmailDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = inboundEmailDELead1.Id);
        emarsysLogsList.add(inboundEmailDELog);

        Emarsys_Log__c otherChannelDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = otherChannelDELead1.Id);
        emarsysLogsList.add(otherChannelDELog);

        // ---------------------- Opportunities ---------------------- //
        String euroShellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        List<Account> accList = new List<Account>();
        Account accountDE = new Account(
            Name = 'test',
            BillingCountry = 'Germany');
        accList.add(accountDE);

        insert accList;

        List<Contact> contactList = new List<Contact>();
        Contact contact = new Contact(
            Email = 'john@wick.com', 
            LastName = 'Wick', 
            FirstName = 'John', 
            Salutation = 'Mr', 
            AccountId = accountDE.Id);
        contactList.add(contact);

        insert contactList;

        List<Opportunity> opportunityToInsertList = new List<Opportunity>();
        Opportunity upgradedToE2EOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Sales_Type__c = 'Manual upgraded to E2E', 
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(upgradedToE2EOpp);

        Opportunity directDebitNoDepositOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitNoDepositOpp);

        Opportunity directDebitAcceptOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'ACCEPT', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitAcceptOpp);

        Opportunity directDebitCancelOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'CANCEL', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitCancelOpp);

        Opportunity directDebitExceptionOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'EXCEPTION', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitExceptionOpp);

        Opportunity bankTransferNoDepositOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            Security_Amount_To_Pay__c = null,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferNoDepositOpp);

        Opportunity bankTransferAcceptOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'ACCEPT', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferAcceptOpp);

        Opportunity bankTransferCancelOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'CANCEL', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferCancelOpp);

        Opportunity bankTransferExceptionOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'EXCEPTION', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferExceptionOpp);

        Opportunity abandonmentScenarioOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOpp);

        Opportunity saveAndContinueOpp = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOpp);

        Opportunity upgradedToE2EOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Sales_Type__c = 'Manual upgraded to E2E', 
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(upgradedToE2EOpp1);

        Opportunity directDebitNoDepositOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitNoDepositOpp1);

        Opportunity directDebitAcceptOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'ACCEPT', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitAcceptOpp1);

        Opportunity directDebitCancelOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'CANCEL', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitCancelOpp1);

        Opportunity directDebitExceptionOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'EXCEPTION', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(directDebitExceptionOpp1);

        Opportunity bankTransferNoDepositOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            Security_Amount_To_Pay__c = null,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferNoDepositOpp1);

        Opportunity bankTransferAcceptOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'ACCEPT', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferAcceptOpp1);

        Opportunity bankTransferCancelOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'CANCEL', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferCancelOpp1);

        Opportunity bankTransferExceptionOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Banküberweisung', 
            E2E_payment_status__c = 'EXCEPTION', 
            Security_Amount_To_Pay__c = 1000,
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(bankTransferExceptionOpp1);

        Opportunity abandonmentScenarioOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOpp1);

        Opportunity saveAndContinueOpp1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountDE.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOpp1);

        insert opportunityToInsertList;

        List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
        OpportunityContactRole upgradedToE2EDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = upgradedToE2EOpp.Id,
            isPrimary = true);
        contactRolesList.add(upgradedToE2EDERole);

        OpportunityContactRole directDebitNoDepositDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitNoDepositOpp.Id,
            isPrimary = true);
        contactRolesList.add(directDebitNoDepositDERole);

        OpportunityContactRole directDebitAcceptDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitAcceptOpp.Id,
            isPrimary = true);
        contactRolesList.add(directDebitAcceptDERole);

        OpportunityContactRole directDebitCancelDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitCancelOpp.Id,
            isPrimary = true);
        contactRolesList.add(directDebitCancelDERole);

        OpportunityContactRole directDebitExceptionDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitExceptionOpp.Id,
            isPrimary = true);
        contactRolesList.add(directDebitExceptionDERole);

        OpportunityContactRole bankTransferNoDepositDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferNoDepositOpp.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferNoDepositDERole);

        OpportunityContactRole bankTransferAcceptDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferAcceptOpp.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferAcceptDERole);

        OpportunityContactRole bankTransferCancelDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferCancelOpp.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferCancelDERole);

        OpportunityContactRole bankTransferExceptionDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferExceptionOpp.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferExceptionDERole);

        OpportunityContactRole abandonmentScenarioDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = abandonmentScenarioOpp.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioDERole);

        OpportunityContactRole saveAndContinueDERole = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = saveAndContinueOpp.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueDERole);

        OpportunityContactRole upgradedToE2EDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = upgradedToE2EOpp1.Id,
            isPrimary = true);
        contactRolesList.add(upgradedToE2EDERole1);

        OpportunityContactRole directDebitNoDepositDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitNoDepositOpp1.Id,
            isPrimary = true);
        contactRolesList.add(directDebitNoDepositDERole1);

        OpportunityContactRole directDebitAcceptDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitAcceptOpp1.Id,
            isPrimary = true);
        contactRolesList.add(directDebitAcceptDERole1);

        OpportunityContactRole directDebitCancelDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitCancelOpp1.Id,
            isPrimary = true);
        contactRolesList.add(directDebitCancelDERole1);

        OpportunityContactRole directDebitExceptionDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = directDebitExceptionOpp1.Id,
            isPrimary = true);
        contactRolesList.add(directDebitExceptionDERole1);

        OpportunityContactRole bankTransferNoDepositDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferNoDepositOpp1.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferNoDepositDERole1);

        OpportunityContactRole bankTransferAcceptDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferAcceptOpp1.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferAcceptDERole1);

        OpportunityContactRole bankTransferCancelDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferCancelOpp1.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferCancelDERole1);

        OpportunityContactRole bankTransferExceptionDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = bankTransferExceptionOpp1.Id,
            isPrimary = true);
        contactRolesList.add(bankTransferExceptionDERole1);

        OpportunityContactRole abandonmentScenarioDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = abandonmentScenarioOpp1.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioDERole1);

        OpportunityContactRole saveAndContinueDERole1 = new OpportunityContactRole(
            ContactId = contact.Id,
            OpportunityId = saveAndContinueOpp1.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueDERole1);

        insert contactRolesList;

        // emarsys de
        Emarsys_Log__c upgradedToE2EDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = upgradedToE2EOpp1.Id);
        emarsysLogsList.add(upgradedToE2EDELog);

        Emarsys_Log__c directDebitNoDepositDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = directDebitNoDepositOpp1.Id);
        emarsysLogsList.add(directDebitNoDepositDELog);

        Emarsys_Log__c directDebitAcceptDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = directDebitAcceptOpp1.Id);
        emarsysLogsList.add(directDebitAcceptDELog);

        Emarsys_Log__c directDebitCancelDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = directDebitCancelOpp1.Id);
        emarsysLogsList.add(directDebitCancelDELog);

        Emarsys_Log__c directDebitExceptionDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = directDebitExceptionOpp1.Id);
        emarsysLogsList.add(directDebitExceptionDELog);

        Emarsys_Log__c bankTransferNoDepositDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = bankTransferNoDepositOpp1.Id);
        emarsysLogsList.add(bankTransferNoDepositDELog);

        Emarsys_Log__c bankTransferAcceptDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = bankTransferAcceptOpp1.Id);
        emarsysLogsList.add(bankTransferAcceptDELog);

        Emarsys_Log__c bankTransferCancelDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = bankTransferCancelOpp1.Id);
        emarsysLogsList.add(bankTransferCancelDELog);

        Emarsys_Log__c bankTransferExceptionDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = bankTransferExceptionOpp1.Id);
        emarsysLogsList.add(bankTransferExceptionDELog);

        Emarsys_Log__c abandonmentScenarioDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = abandonmentScenarioOpp1.Id);
        emarsysLogsList.add(abandonmentScenarioDELog);

        Emarsys_Log__c saveAndContinueDELog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = saveAndContinueOpp1.Id);
        emarsysLogsList.add(saveAndContinueDELog);

        insert emarsysLogsList;
    }

    private static void createDataNL() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;

        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        List<Lead> leadsToInsertList = new List<Lead>();
        Lead inboundCallNLLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallNLLead);

        Lead shellNLLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Shell Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(shellNLLead);

        // Netherlands 
        Lead facebookNLLead2 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookNLLead2);

        Lead inboundCallNLLead2 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallNLLead2);

        Lead inboundEmailNLLead2 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailNLLead2);

        Lead shellEmailNLLead2 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Netherlands',
            Email = 'test@test.com',
            LeadSource = 'Shell Email',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(shellEmailNLLead2);
        insert leadsToInsertList;

        // Netherlands logs
       List<Emarsys_Log__c> emarsysLogsList = new List<Emarsys_Log__c>();
        Emarsys_Log__c facebookNLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = facebookNLLead2.Id);
        emarsysLogsList.add(facebookNLLog);

        Emarsys_Log__c inboundCallNLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = inboundCallNLLead2.Id);
        emarsysLogsList.add(inboundCallNLLog);

        Emarsys_Log__c inboundEmailNLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = inboundEmailNLLead2.Id);
        emarsysLogsList.add(inboundEmailNLLog);

        Emarsys_Log__c shellEmailNLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = shellEmailNLLead2.Id);
        emarsysLogsList.add(shellEmailNLLog);

        // Opportunity
        String euroShellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        List<Account> accList = new List<Account>();
        Account accountNL = new Account(
            Name = 'test',
            BillingCountry = 'Netherlands');
        accList.add(accountNL);
        insert accList;

        List<Contact> contactList = new List<Contact>();
        Contact contactNL = new Contact(
            Email = 'john@wick.com', 
            LastName = 'Wick', 
            FirstName = 'John', 
            Salutation = 'Mr', 
            AccountId = accountNL.Id);
        contactList.add(contactNL);
        insert contactList;

        // Netherlands
        List<Opportunity> opportunityToInsertList = new List<Opportunity>();
        Opportunity upgradedToE2EOppNL = new Opportunity(
            Name = 'test app', 
            AccountId = accountNL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Sales_Type__c = 'Manual upgraded to E2E', 
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(upgradedToE2EOppNL);

        Opportunity orderConfirmationOppNL = new Opportunity(
            Name = 'test app', 
            AccountId = accountNL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppNL);

        Opportunity abandonmentScenarioOppNL = new Opportunity(
            Name = 'test app', 
            AccountId = accountNL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppNL);

        Opportunity saveAndContinueOppNL = new Opportunity(
            Name = 'test app', 
            AccountId = accountNL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppNL);

        Opportunity upgradedToE2EOppNL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountNL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Sales_Type__c = 'Manual upgraded to E2E', 
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(upgradedToE2EOppNL1);

        Opportunity orderConfirmationOppNL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountNL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppNL1);

        Opportunity abandonmentScenarioOppNL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountNL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppNL1);

        Opportunity saveAndContinueOppNL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountNL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppNL1);
        insert opportunityToInsertList;

        // Netherlands
        List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
        OpportunityContactRole upgradedToE2ENLRole = new OpportunityContactRole(
            ContactId = contactNL.Id,
            OpportunityId = upgradedToE2EOppNL.Id,
            isPrimary = true);
        contactRolesList.add(upgradedToE2ENLRole);

        OpportunityContactRole orderConfirmationNLRole = new OpportunityContactRole(
            ContactId = contactNL.Id,
            OpportunityId = orderConfirmationOppNL.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationNLRole);

        OpportunityContactRole abandonmentScenarioNLRole = new OpportunityContactRole(
            ContactId = contactNL.Id,
            OpportunityId = abandonmentScenarioOppNL.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioNLRole);

        OpportunityContactRole saveAndContinueNLRole = new OpportunityContactRole(
            ContactId = contactNL.Id,
            OpportunityId = saveAndContinueOppNL.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueNLRole);

        OpportunityContactRole upgradedToE2ENLRole1 = new OpportunityContactRole(
            ContactId = contactNL.Id,
            OpportunityId = upgradedToE2EOppNL1.Id,
            isPrimary = true);
        contactRolesList.add(upgradedToE2ENLRole1);

        OpportunityContactRole orderConfirmationNLRole1 = new OpportunityContactRole(
            ContactId = contactNL.Id,
            OpportunityId = orderConfirmationOppNL1.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationNLRole1);

        OpportunityContactRole abandonmentScenarioNLRole1 = new OpportunityContactRole(
            ContactId = contactNL.Id,
            OpportunityId = abandonmentScenarioOppNL1.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioNLRole1);

        OpportunityContactRole saveAndContinueNLRole1 = new OpportunityContactRole(
            ContactId = contactNL.Id,
            OpportunityId = saveAndContinueOppNL1.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueNLRole1);
        insert contactRolesList;

        // NL
        Emarsys_Log__c upgradedToE2ENLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = upgradedToE2EOppNL1.Id);
        emarsysLogsList.add(upgradedToE2ENLLog);

        Emarsys_Log__c orderConfirmationNLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = orderConfirmationOppNL1.Id);
        emarsysLogsList.add(orderConfirmationNLLog);

        Emarsys_Log__c abandonmentScenarioNLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = abandonmentScenarioOppNL1.Id);
        emarsysLogsList.add(abandonmentScenarioNLLog);

        Emarsys_Log__c saveAndContinueNLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = saveAndContinueOppNL1.Id);
        emarsysLogsList.add(saveAndContinueNLLog);
        insert emarsysLogsList;
    }

    private static void createDataBENL() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;

        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        List<Lead> leadsToInsertList = new List<Lead>();
        Lead inboundEmailBENLLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailBENLLead);

        Lead facebookNBELLead3 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookNBELLead3);

        Lead inboundCallBENLLead3 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallBENLLead3);

        Lead inboundEmailBENLLead3 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailBENLLead3);

        Lead shellEmailBENLLead3 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-NL',
            Email = 'test@test.com',
            LeadSource = 'Shell Email',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(shellEmailBENLLead3);

        insert leadsToInsertList;

        List<Emarsys_Log__c> emarsysLogsList = new List<Emarsys_Log__c>();
        // Belgium-NL logs
        Emarsys_Log__c facebookBENLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = facebookNBELLead3.Id);
        emarsysLogsList.add(facebookBENLLog);

        Emarsys_Log__c inboundCallBENLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = inboundCallBENLLead3.Id);
        emarsysLogsList.add(inboundCallBENLLog);

        Emarsys_Log__c inboundEmailBENLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = inboundEmailBENLLead3.Id);
        emarsysLogsList.add(inboundEmailBENLLog);

        Emarsys_Log__c shellEmailBENLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = shellEmailBENLLead3.Id);
        emarsysLogsList.add(shellEmailBENLLog);

        // ---------------------- Opportunities ---------------------- //
        String euroShellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        List<Account> accList = new List<Account>();
        Account accountBENL = new Account(
            Name = 'test',
            BillingCountry = 'Belgium-NL');
        accList.add(accountBENL);

        insert accList;

        List<Contact> contactList = new List<Contact>();
        Contact contactBENL = new Contact(
            Email = 'john@wick.com', 
            LastName = 'Wick', 
            FirstName = 'John', 
            Salutation = 'Mr', 
            AccountId = accountBENL.Id);
        contactList.add(contactBENL);
        insert contactList;

        // Belgium-NL
        List<Opportunity> opportunityToInsertList = new List<Opportunity>();
        Opportunity orderConfirmationOppBENL = new Opportunity(
            Name = 'test app', 
            AccountId = accountBENL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppBENL);

        Opportunity abandonmentScenarioOppBENL = new Opportunity(
            Name = 'test app', 
            AccountId = accountBENL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppBENL);

        Opportunity saveAndContinueOppBENL = new Opportunity(
            Name = 'test app', 
            AccountId = accountBENL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppBENL);

        Opportunity orderConfirmationOppBENL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountBENL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppBENL1);

        Opportunity abandonmentScenarioOppBENL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountBENL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppBENL1);

        Opportunity saveAndContinueOppBENL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountBENL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppBENL1);
        insert opportunityToInsertList;

        List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
        OpportunityContactRole orderConfirmationBENLRole = new OpportunityContactRole(
            ContactId = contactBENL.Id,
            OpportunityId = orderConfirmationOppBENL.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationBENLRole);

        OpportunityContactRole abandonmentScenarioBENLRole = new OpportunityContactRole(
            ContactId = contactBENL.Id,
            OpportunityId = abandonmentScenarioOppBENL.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioBENLRole);

        OpportunityContactRole saveAndContinueBENLRole = new OpportunityContactRole(
            ContactId = contactBENL.Id,
            OpportunityId = saveAndContinueOppBENL.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueBENLRole);

        OpportunityContactRole orderConfirmationBENLRole1 = new OpportunityContactRole(
            ContactId = contactBENL.Id,
            OpportunityId = orderConfirmationOppBENL1.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationBENLRole1);

        OpportunityContactRole abandonmentScenarioBENLRole1 = new OpportunityContactRole(
            ContactId = contactBENL.Id,
            OpportunityId = abandonmentScenarioOppBENL1.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioBENLRole1);

        OpportunityContactRole saveAndContinueBENLRole1 = new OpportunityContactRole(
            ContactId = contactBENL.Id,
            OpportunityId = saveAndContinueOppBENL1.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueBENLRole1);
        insert contactRolesList;

        // BENL
        Emarsys_Log__c orderConfirmationBENLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = orderConfirmationOppBENL1.Id);
        emarsysLogsList.add(orderConfirmationBENLLog);

        Emarsys_Log__c abandonmentScenarioBENLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = abandonmentScenarioOppBENL1.Id);
        emarsysLogsList.add(abandonmentScenarioBENLLog);

        Emarsys_Log__c saveAndContinueBENLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = saveAndContinueOppBENL1.Id);
        emarsysLogsList.add(saveAndContinueBENLLog);
        insert emarsysLogsList;
    }

    private static void createDataBEFR() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;

        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        List<Lead> leadsToInsertList = new List<Lead>();
        Lead inboundEmailBEFRLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailBEFRLead);

        // Belgium-FR 
        Lead facebookBEFRLead4 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            LeadSource = 'Facebook', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(facebookBEFRLead4);

        Lead inboundCallBEFRLead4 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            LeadSource = 'Inbound Call', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundCallBEFRLead4);

        Lead inboundEmailBEFRLead4 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            LeadSource = 'Inbound Email', 
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(inboundEmailBEFRLead4);

        Lead shellEmailBEFRLead4 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Belgium-FR',
            Email = 'test@test.com',
            LeadSource = 'Shell Email',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(shellEmailBEFRLead4);
        insert leadsToInsertList;

        List<Emarsys_Log__c> emarsysLogsList = new List<Emarsys_Log__c>();
        // Belgium-FR logs
        Emarsys_Log__c facebookBEFRLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = facebookBEFRLead4.Id);
        emarsysLogsList.add(facebookBEFRLog);

        Emarsys_Log__c inboundCallBEFRLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = inboundCallBEFRLead4.Id);
        emarsysLogsList.add(inboundCallBEFRLog);

        Emarsys_Log__c inboundEmailBEFRLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = inboundEmailBEFRLead4.Id);
        emarsysLogsList.add(inboundEmailBEFRLog);

        Emarsys_Log__c shellEmailBEFRLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = shellEmailBEFRLead4.Id);
        emarsysLogsList.add(shellEmailBEFRLog);

        // ---------------------- Opportunities ---------------------- //
        String euroShellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        List<Account> accList = new List<Account>();
        Account accountBEFR = new Account(
            Name = 'test',
            BillingCountry = 'Belgium-FR');
        accList.add(accountBEFR);
        insert accList;

        List<Contact> contactList = new List<Contact>();
        Contact contactBEFR = new Contact(
            Email = 'john@wick.com', 
            LastName = 'Wick', 
            FirstName = 'John', 
            Salutation = 'Mr', 
            AccountId = accountBEFR.Id);
        contactList.add(contactBEFR);
        insert contactList;

        List<Opportunity> opportunityToInsertList = new List<Opportunity>();
        // Belgium-FR
        Opportunity orderConfirmationOppBEFR = new Opportunity(
            Name = 'test app', 
            AccountId = accountBEFR.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppBEFR);

        Opportunity abandonmentScenarioOppBEFR = new Opportunity(
            Name = 'test app', 
            AccountId = accountBEFR.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppBEFR);

        Opportunity saveAndContinueOppBEFR = new Opportunity(
            Name = 'test app', 
            AccountId = accountBEFR.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppBEFR);

        Opportunity orderConfirmationOppBEFR1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountBEFR.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppBEFR1);

        Opportunity abandonmentScenarioOppBEFR1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountBEFR.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppBEFR1);

        Opportunity saveAndContinueOppBEFR1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountBEFR.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppBEFR1);
        insert opportunityToInsertList;

        // Belgium-FR
        List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
        OpportunityContactRole orderConfirmationBEFRRole = new OpportunityContactRole(
            ContactId = contactBEFR.Id,
            OpportunityId = orderConfirmationOppBEFR.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationBEFRRole);

        OpportunityContactRole abandonmentScenarioBEFRRole = new OpportunityContactRole(
            ContactId = contactBEFR.Id,
            OpportunityId = abandonmentScenarioOppBEFR.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioBEFRRole);

        OpportunityContactRole saveAndContinueBEFRRole = new OpportunityContactRole(
            ContactId = contactBEFR.Id,
            OpportunityId = saveAndContinueOppBEFR.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueBEFRRole);

        OpportunityContactRole orderConfirmationBEFRRole1 = new OpportunityContactRole(
            ContactId = contactBEFR.Id,
            OpportunityId = orderConfirmationOppBEFR1.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationBEFRRole1);

        OpportunityContactRole abandonmentScenarioBEFRRole1 = new OpportunityContactRole(
            ContactId = contactBEFR.Id,
            OpportunityId = abandonmentScenarioOppBEFR1.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioBEFRRole1);

        OpportunityContactRole saveAndContinueBEFRRole1 = new OpportunityContactRole(
            ContactId = contactBEFR.Id,
            OpportunityId = saveAndContinueOppBEFR1.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueBEFRRole1);
        insert contactRolesList;

        // BEFR
        Emarsys_Log__c orderConfirmationBEFRLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = orderConfirmationOppBEFR1.Id);
        emarsysLogsList.add(orderConfirmationBEFRLog);

        Emarsys_Log__c abandonmentScenarioBEFRLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = abandonmentScenarioOppBEFR1.Id);
        emarsysLogsList.add(abandonmentScenarioBEFRLog);

        Emarsys_Log__c saveAndContinueBEFRLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = saveAndContinueOppBEFR1.Id);
        emarsysLogsList.add(saveAndContinueBEFRLog);
        insert emarsysLogsList;
    }

    private static void createDataPL() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;

        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        List<Lead> leadsToInsertList = new List<Lead>();
        // Poland
        Lead otherChannelPLLead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Poland',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelPLLead);

        Lead otherChannelPLLead5 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Poland',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelPLLead5);
        insert leadsToInsertList;

        // Poland logs
        List<Emarsys_Log__c> emarsysLogsList = new List<Emarsys_Log__c>();
        Emarsys_Log__c otherChannelPLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = otherChannelPLLead5.Id);
        emarsysLogsList.add(otherChannelPLLog);

        String euroShellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        List<Account> accList = new List<Account>();
        Account accountPL = new Account(
            Name = 'test',
            BillingCountry = 'Poland');
        accList.add(accountPL);
        insert accList;

        List<Contact> contactList = new List<Contact>();
        Contact contactPL = new Contact(
            Email = 'john@wick.com', 
            LastName = 'Wick', 
            FirstName = 'John', 
            Salutation = 'Mr', 
            AccountId = accountPL.Id);
        contactList.add(contactPL);
        insert contactList;

        List<Opportunity> opportunityToInsertList = new List<Opportunity>();
        // Poland
        Opportunity orderConfirmationOppPL = new Opportunity(
            Name = 'test app', 
            AccountId = accountPL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppPL);

        Opportunity abandonmentScenarioOppPL = new Opportunity(
            Name = 'test app', 
            AccountId = accountPL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppPL);

        Opportunity saveAndContinueOppPL = new Opportunity(
            Name = 'test app', 
            AccountId = accountPL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppPL);

        Opportunity orderConfirmationOppPL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountPL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppPL1);

        Opportunity abandonmentScenarioOppPL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountPL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppPL1);

        Opportunity saveAndContinueOppPL1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountPL.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppPL1);
        insert opportunityToInsertList;

        List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
        // Poland
        OpportunityContactRole orderConfirmationPLRole = new OpportunityContactRole(
            ContactId = contactPL.Id,
            OpportunityId = orderConfirmationOppPL.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationPLRole);

        OpportunityContactRole abandonmentScenarioPLRole = new OpportunityContactRole(
            ContactId = contactPL.Id,
            OpportunityId = abandonmentScenarioOppPL.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioPLRole);

        OpportunityContactRole saveAndContinuePLRole = new OpportunityContactRole(
            ContactId = contactPL.Id,
            OpportunityId = saveAndContinueOppPL.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinuePLRole);

        OpportunityContactRole orderConfirmationPLRole1 = new OpportunityContactRole(
            ContactId = contactPL.Id,
            OpportunityId = orderConfirmationOppPL1.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationPLRole1);

        OpportunityContactRole abandonmentScenarioPLRole1 = new OpportunityContactRole(
            ContactId = contactPL.Id,
            OpportunityId = abandonmentScenarioOppPL1.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioPLRole1);

        OpportunityContactRole saveAndContinuePLRole1 = new OpportunityContactRole(
            ContactId = contactPL.Id,
            OpportunityId = saveAndContinueOppPL1.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinuePLRole1);
        insert contactRolesList;

        // PL
        Emarsys_Log__c orderConfirmationPLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = orderConfirmationOppPL1.Id);
        emarsysLogsList.add(orderConfirmationPLLog);

        Emarsys_Log__c abandonmentScenarioPLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = abandonmentScenarioOppPL1.Id);
        emarsysLogsList.add(abandonmentScenarioPLLog);

        Emarsys_Log__c saveAndContinuePLLog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = saveAndContinueOppPL1.Id);
        emarsysLogsList.add(saveAndContinuePLLog);
        insert emarsysLogsList;
    }

    private static void createDataHU() {
        AccountTriggerHandler.enablesTrigger = false;
        ContactTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.enablesTrigger = false;
        OpportunityTriggerHandler.isE2EForm = true;

        String endkundeRecId = GlobalUtils.returnRecordTypeId('Lead', 'Endkunde');
        List<Lead> leadsToInsertList = new List<Lead>();
        Lead otherChannelHULead = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Hungary',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelHULead);

        // Hungary
        Lead otherChannelHULead6 = new Lead(
            LastName = 'test',
            Company = 'test',
            Country = 'Hungary',
            Email = 'test@test.com',
            Sec_Channel__c = 'JITB',
            Quali_Status__c = 'Switched to E2E', 
            CreatedDate = Datetime.now().addDays(-15),
            RecordTypeId = endkundeRecId);
        leadsToInsertList.add(otherChannelHULead6);
        insert leadsToInsertList;

        List<Emarsys_Log__c> emarsysLogsList = new List<Emarsys_Log__c>();
        // Hungary logs
        Emarsys_Log__c otherChannelHULog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Lead__c = otherChannelHULead6.Id);
        emarsysLogsList.add(otherChannelHULog);

        // ---------------------- Opportunities ---------------------- //
        String euroShellRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'Euroshell');
        List<Account> accList = new List<Account>();
        Account accountHU = new Account(
            Name = 'test',
            BillingCountry = 'Hungary');
        accList.add(accountHU);
        insert accList;

        List<Contact> contactList = new List<Contact>();
        Contact contactHU = new Contact(
            Email = 'john@wick.com', 
            LastName = 'Wick', 
            FirstName = 'John', 
            Salutation = 'Mr', 
            AccountId = accountHU.Id);
        contactList.add(contactHU);
        insert contactList;

        List<Opportunity> opportunityToInsertList = new List<Opportunity>();
        // Hungary
        Opportunity orderConfirmationOppHU = new Opportunity(
            Name = 'test app', 
            AccountId = accountHU.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppHU);

        Opportunity abandonmentScenarioOppHU = new Opportunity(
            Name = 'test app', 
            AccountId = accountHU.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppHU);

        Opportunity saveAndContinueOppHU = new Opportunity(
            Name = 'test app', 
            AccountId = accountHU.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppHU);

        Opportunity orderConfirmationOppHU1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountHU.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            Zahlungsart__c = 'Lastschrift', 
            E2E_payment_status__c = 'NO DEPOSIT', 
            E2E_Active_Step__c = 4,
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(orderConfirmationOppHU1);

        Opportunity abandonmentScenarioOppHU1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountHU.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (hard)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(abandonmentScenarioOppHU1);

        Opportunity saveAndContinueOppHU1 = new Opportunity(
            Name = 'test app', 
            AccountId = accountHU.Id, 
            RecordTypeId = euroShellRecId, 
            E2E__c = true, 
            CreatedDate = Datetime.now().addDays(-15), 
            E2E_Switch_To_Manual__c = false, 
            E2E_Status__c = 'Abandoned (soft)', 
            E2E_Sub_Status__c = 'Marketing automation',
            StageName = 'Prospecting', 
            Sec_Channel__c = 'Inbound', 
            CloseDate = Date.today()); 
        opportunityToInsertList.add(saveAndContinueOppHU1);
        insert opportunityToInsertList;

        List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
        // Hungary
        OpportunityContactRole orderConfirmationHURole = new OpportunityContactRole(
            ContactId = contactHU.Id,
            OpportunityId = orderConfirmationOppHU.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationHURole);

        OpportunityContactRole abandonmentScenarioHURole = new OpportunityContactRole(
            ContactId = contactHU.Id,
            OpportunityId = abandonmentScenarioOppHU.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioHURole);

        OpportunityContactRole saveAndContinueHURole = new OpportunityContactRole(
            ContactId = contactHU.Id,
            OpportunityId = saveAndContinueOppHU.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueHURole);

        OpportunityContactRole orderConfirmationHURole1 = new OpportunityContactRole(
            ContactId = contactHU.Id,
            OpportunityId = orderConfirmationOppHU1.Id,
            isPrimary = true);
        contactRolesList.add(orderConfirmationHURole1);

        OpportunityContactRole abandonmentScenarioHURole1 = new OpportunityContactRole(
            ContactId = contactHU.Id,
            OpportunityId = abandonmentScenarioOppHU1.Id,
            isPrimary = true);
        contactRolesList.add(abandonmentScenarioHURole1);

        OpportunityContactRole saveAndContinueHURole1 = new OpportunityContactRole(
            ContactId = contactHU.Id,
            OpportunityId = saveAndContinueOppHU1.Id,
            isPrimary = true);
        contactRolesList.add(saveAndContinueHURole1);
        insert contactRolesList;

        // HU
        Emarsys_Log__c orderConfirmationHULog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = orderConfirmationOppHU1.Id);
        emarsysLogsList.add(orderConfirmationHULog);

        Emarsys_Log__c abandonmentScenarioHULog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = abandonmentScenarioOppHU1.Id);
        emarsysLogsList.add(abandonmentScenarioHULog);

        Emarsys_Log__c saveAndContinueHULog = new Emarsys_Log__c(
            Email_Name__c = 'test', 
            CreatedDate = Datetime.now().addDays(-7), 
            Opportunity__c = saveAndContinueOppHU1.Id);
        emarsysLogsList.add(saveAndContinueHULog);

        insert emarsysLogsList;
    }

	@isTest
    static void emarsysJobTestDE() {
        Test.startTest();
            createDataDE();
	        EmarsysLogCheckerSchedule schedule = new EmarsysLogCheckerSchedule();
			String sch = '0 0 0 15 3 ? 2023'; 
			System.schedule('Emarsys log checker Job', sch, schedule);
		Test.stopTest();
    }

    @isTest
    static void emarsysJobTestNL() {
        Test.startTest();
            createDataNL();
            EmarsysLogCheckerSchedule schedule = new EmarsysLogCheckerSchedule();
            String sch = '0 0 0 15 3 ? 2023'; 
            System.schedule('Emarsys log checker Job', sch, schedule);
        Test.stopTest();
    }

    @isTest
    static void emarsysJobTestBENL() {
        Test.startTest();
            createDataBENL();
            EmarsysLogCheckerSchedule schedule = new EmarsysLogCheckerSchedule();
            String sch = '0 0 0 15 3 ? 2023'; 
            System.schedule('Emarsys log checker Job', sch, schedule);
        Test.stopTest();
    }

    @isTest
    static void emarsysJobTestBEFR() {
        Test.startTest();
            createDataBEFR();
            EmarsysLogCheckerSchedule schedule = new EmarsysLogCheckerSchedule();
            String sch = '0 0 0 15 3 ? 2023'; 
            System.schedule('Emarsys log checker Job', sch, schedule);
        Test.stopTest();
    }

    @isTest
    static void emarsysJobTestPL() {
        Test.startTest();
            createDataPL();
            EmarsysLogCheckerSchedule schedule = new EmarsysLogCheckerSchedule();
            String sch = '0 0 0 15 3 ? 2023'; 
            System.schedule('Emarsys log checker Job', sch, schedule);
        Test.stopTest();
    }

    @isTest
    static void emarsysJobTestHU() {
        Test.startTest();
            createDataHU();
            EmarsysLogCheckerSchedule schedule = new EmarsysLogCheckerSchedule();
            String sch = '0 0 0 15 3 ? 2023'; 
            System.schedule('Emarsys log checker Job', sch, schedule);
        Test.stopTest();
    }
}