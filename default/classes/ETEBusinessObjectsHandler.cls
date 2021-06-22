public virtual class ETEBusinessObjectsHandler implements ETEBusinessObjectsInterface {

    public virtual E2E_Data_Object__c initDataObject(List<String> availableStepsList, String countryCode, String implKey) {
        String recordTypeId = Schema.SObjectType.E2E_Data_Object__c.getRecordTypeInfosByName().get(implKey).getRecordTypeId();
        E2E_Data_Object__c dataObject = new E2E_Data_Object__c();
        dataObject.Name = 'NEW E2E CUSTOMER';
        dataObject.Selected_Company_Name__c = 'NEW E2E CUSTOMER';
        dataObject.StageName__c = 'Prospecting';
        dataObject.E2E_Status__c = 'In progress';
        dataObject.RecordTypeId = recordTypeId;
        dataObject.Country_Code__c = countryCode;
        dataObject.Current_Step__c = availableStepsList.get(0);
        dataObject.Current_Language__c = ETEGlobalUtils.returnDefaultLanguage(countryCode);
        dataObject.CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(countryCode);
        dataObject.E2E_Last_Activity__c = Datetime.now();
        dataObject.Registered_Country__c = ETEGlobalUtils.returnCountry(countryCode);
        return dataObject;
    }


    public virtual Opportunity initOpportunity(E2E_Data_Object__c dataObject, String priceBookId) {
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Euroshell').getRecordTypeId();
        Opportunity newOppty = new Opportunity(
                RecordTypeId = recordTypeId,
                Name = dataObject.Selected_Company_Name__c,
                E2E_Data_Object__c = dataObject.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Last_Owner_Change_Date__c = Datetime.now(),
                Language_preference__c = ETEGlobalUtils.returnLanguagePreference(dataObject.Current_Language__c),
                E2E_Step__c = dataObject.Current_Step__c,
                E2E_Encoded_URL__c = ETEGlobalUtils.doEncryptParams(dataObject.Id, dataObject.Country_Code__c),
                Device_Type__c = dataObject.Device_Type__c,
                Visitor_ID__c = dataObject.Customer_IP_Address__c,
                E2E_Last_Activity__c = dataObject.E2E_Last_Activity__c,
                E2E_2__c = true,
                Eco_Fee__c = false,
                LeadSource = 'E2E Form',
                Direct_Debit_Mandate_Type__c = '',
                Bevollmaechtigung__c = false,
                Sec_Channel__c = 'Inbound',
                Channel__c = 'Internet',
                Product__c = '',
                CurrencyIsoCode = ETEGlobalUtils.returnCurrencyCode(dataObject.Country_Code__c),
                Type = 'New Business',
                AGB_Datenschutzhinweise_Richtigkeit__c = false,
                E2E_Status__c = 'In progress',
                E2E_Sales_Type__c = 'Fully E2E',
                Utm_campaign__c = dataObject.Utm_Campaign__c,
                Utm_content__c = dataObject.Utm_Content__c,
                Utm_medium__c = dataObject.Utm_Medium__c,
                Utm_placement__c = dataObject.Utm_Placement__c,
                Utm_source__c = dataObject.Utm_Source__c,
                Utm_term__c = dataObject.Utm_Term__c,
                Utm_url__c = dataObject.Utm_Url__c,
                PriceBook2Id = priceBookId
        );
        return newOppty;
    }


    public virtual CreditFactoryCompany getCFReport(CreditFactory creditFactory, String opptyId) {
        CreditFactoryReportsItem reportsItem = creditFactory.selectCompanyReports(opptyId);
        CreditFactoryCompany creditFactoryCompany;
        for (CreditFactoryCompany cfCompany : reportsItem.companiesList) {
            if (cfCompany != null && cfCompany.recordType == 'Default') {
                creditFactoryCompany = cfCompany;
            }
        }

        if (creditFactoryCompany != null && creditFactoryCompany.name == null) {
            for (CreditFactoryCompany cfCompany : reportsItem.companiesList) {
                if (cfCompany != null && cfCompany.recordType == 'Company Info') {
                    creditFactoryCompany = cfCompany;
                }
            }
        }

        return creditFactoryCompany;
    }


    public virtual Account initAccount(String country, E2E_Data_Object__c dataObject) {
        String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Endkunde').getRecordTypeId();
        Account account = new Account(
                Name = dataObject.Selected_Company_Name__c,
                RecordTypeId = recordTypeId,
                Type = 'Customer',
                E2E__c = true,
                Sec_Channel__c = 'Inbound',
                Sec_Channel_Acc__c = 'Inbound',
                AccountSource = 'E2E Form',
                BillingCountry = country
        );
        return account;
    }


    public virtual Contact initContact() {
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact layout').getRecordTypeId();
        Contact contact = new Contact(
                RecordTypeId = recordTypeId,
                Authorised_signatory__c = false,
                E2E__c = true
        );
        return contact;
    }


    public virtual OpportunityContactRole initOpportunityContactRole() {
        OpportunityContactRole ocr = new OpportunityContactRole(
                IsPrimary = true
        );
        return ocr;
    }
}
