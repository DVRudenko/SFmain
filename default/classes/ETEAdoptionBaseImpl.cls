public virtual class ETEAdoptionBaseImpl implements ETEAdoptionInterface {


    public virtual Database.LeadConvertResult convertLeadToE2E(E2E_Data_Object__c e2eDataObject, Account account, Opportunity opportunity, Contact contact) {
        Database.LeadConvertResult lcr;
        try {
            LeadHandler.enablesTrigger = false;
            OpportunityTriggerHandler.enablesTrigger = false;
            Database.LeadConvert lc = new Database.LeadConvert();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setLeadId(e2eDataObject.Lead__c);
            lc.setAccountId(account.Id);
            lc.setOpportunityId(opportunity.Id);
            lc.setContactId(contact.Id);
            lcr = Database.convertLead(lc);
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf('ETEAdoptionBaseImpl, lead Id: ' + e2eDataObject.Lead__c + ', ' + e.getMessage()), String.valueOf(e.getStackTraceString()));
        }
        return lcr;
    }


    public virtual Lead updateLead(Lead lead) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance(lead.Country);
        if ( settings != null ) {
            lead.OwnerId = settings.Integration_Admin_Id__c;
            if (lead.E2E_Manual_Adoption_Date__c != null) {
                lead.E2E_Assistant__c = lead.Owner.Name;
            }
        }
        lead.E2E_Adoption_Status__c = 'Successful Adoption';

        update lead;
        return lead;
    }


    public virtual Account insertAccount(E2E_Data_Object__c e2eDataObject, Lead lead) {
        String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Endkunde').getRecordTypeId();
        Account account = new Account(
                Name = e2eDataObject.Company_Short_Name__c,
                RecordTypeId = recordTypeId,
                CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(e2eDataObject.Country_Code__c),
                Type = 'Customer',
                E2E__c = true,
                Sec_Channel__c = lead.Sec_Channel__c,
                Sec_Channel_Acc__c = lead.Sec_Channel__c,
                AccountSource = lead.LeadSource,
                BillingCountry = lead.Country
        );
        insert account;
        return account;
    }


    public virtual Opportunity insertOpportunity(E2E_Data_Object__c e2eDataObject, Lead lead, Account account) {
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Euroshell').getRecordTypeId();
        String language = ETEGlobalUtils.returnDefaultLanguage(lead.CountryCode.toLowerCase());
        String pricebookId;
        if (Test.isRunningTest()) {
            pricebookId = Test.getStandardPricebookId();
        } else {
            pricebookId = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book'].Id;
        }
        Opportunity opportunity = new Opportunity(
            Name = e2eDataObject.Company_Short_Name__c,
            CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(e2eDataObject.Country_Code__c),
            AccountId = account.Id,
            Pricebook2Id = pricebookId,
            E2E_Adoption_Status__c = 'Successful Adoption',
            E2E_Adoption_Date__c = Date.today(),
            StageName = 'Prospecting',
            RecordTypeId = recordTypeId,
            Primary_Contact_Phone__c = lead.Phone,
            CloseDate = Date.today(),
            Last_Owner_Change_Date__c = Datetime.now(),
            Product__c = null,
            E2E_Data_Object__c = e2EDataObject.Id,
            E2E_2__c = true,
            E2E_Step__c = 'products_and_services',
            E2E_Encoded_URL__c = ETEGlobalUtils.doEncryptParams(e2EDataObject.Id, lead.CountryCode.toLowerCase()),
            E2E_Active_Step__c = 0,
            E2E_Sales_Type__c = 'Fully E2E',
            E2E_Status__c = 'Introduction',
            E2E_Sub_Status__c = 'Marketing automation',
            AGB_Datenschutzhinweise_Richtigkeit__c = false,
            E2E_Form_of_Business__c = 'Company',
            Description = lead.Description,
            Language_preference__c = ETEGlobalUtils.returnLanguagePreference(language),
            Agree_to_telephone_contact__c = lead.Agree_to_telephone_contact__c,
            Agree_to_receive_comm_info_by_email__c = lead.Agree_to_receive_comm_info_by_email__c,
            Agree_to_process_pers_data_for_marketing__c = lead.Agree_to_process_pers_data_for_marketing__c
        );

        insert opportunity;
        return opportunity;
    }


    public virtual Contact insertContact(E2E_Data_Object__c e2eDataObject, Account account, E2E_Data_Contact__c e2EDataContact) {
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact layout').getRecordTypeId();
        Contact contact = new Contact(
            RecordTypeId = recordTypeId,
            Authorised_signatory__c = false,
            CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(e2eDataObject.Country_Code__c),
            E2E__c = true,
            FirstName = e2EDataContact.First_Name__c,
            LastName = e2EDataContact.Last_Name__c,
            Salutation = e2EDataContact.Salutation__c,
            Phone = e2EDataContact.Phone__c,
            Email = e2EDataContact.Email__c,
            AccountId = account.Id
        );

        insert contact;
        return contact;
    }


    public virtual void insertOpportunityContactRole(Opportunity opportunity, Contact contact) {
        OpportunityContactRole oppConRole = new OpportunityContactRole(
            IsPrimary = true,
            OpportunityId = opportunity.Id,
            ContactId = contact.Id
        );
        insert oppConRole;
    }


    public virtual List<Emarsys_Log__c> setFieldsToUpdateEmarsysLogs(List<Emarsys_Log__c> emarsysLogs, Opportunity opportunity) {
        for (Emarsys_Log__c emarsysLog : emarsysLogs) {
            emarsysLog.Opportunity__c = opportunity.Id;
        }
        return emarsysLogs;
    }
}