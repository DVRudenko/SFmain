public virtual class ETEAdoptionLotosBaseImpl extends ETEAdoptionBaseImpl {


    public override Opportunity insertOpportunity(E2E_Data_Object__c e2eDataObject, Lead lead, Account account) {
        String recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lotos').getRecordTypeId();
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
            StageName = 'Qualify',
            RecordTypeId = recordTypeId,
            Primary_Contact_Phone__c = lead.ConvertedContact.Phone,
            Product__c = null,
            E2E_Data_Object__c = e2EDataObject.Id,
            CloseDate = Date.today(),
            Last_Owner_Change_Date__c = Datetime.now(),
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
            Language_preference__c = ETEGlobalUtils.returnLanguagePreference(language)
        );

        insert opportunity;
        return opportunity;
    }
}