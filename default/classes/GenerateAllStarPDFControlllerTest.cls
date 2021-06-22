@isTest
private class GenerateAllStarPDFControlllerTest {
	public static Account newAccount;
    public static Account newSubAccount;
    public static Opportunity newOpportunity;
    public static Contact newContact;
  
  /*******************************************************************************
    *  Name            : testGeneratePdf()
    *  Summary         : testing generate pdf 
    *  CreatedDate     : 31/05/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testGeneratePdf() {
        createParentAccount();
        createOpportunity();
        createContact();
        createSubAccount();
    	Apexpages.currentPage().getParameters().put('id', newOpportunity.Id);
    	GenerateAllStarPDFControlller controller = new GenerateAllStarPDFControlller();
    	controller.init();
	}


	private static void createParentAccount() {
        List<Account> accountsList = new List<Account>();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Account' LIMIT 1];
        newAccount = new Account(
            RecordTypeId = rt.Id,
            Name = 'test account',
            Trading_Name__c = 'test trading name',
            NIP__c = '1234567899',
            REGON__c = '9987654321',
            KRS__c = '1234554321',
            Gesellschaftsform__c = 'Sole trader',
            Phone = '+48 7777777',
            Mobile_Phone__c = '+48 3333333',
            Website = 'testsite.com',
            BillingStreet = 'street name',
            BillingCity = 'Warsaw',
            BillingPostalCode = '123455',
            Allstar_Email__c = 'test@test.com',
            BillingCountry = 'Poland',
            ShippingStreet = 'shipping street',
            ShippingCity = 'Warsaw',
            ShippingPostalCode = '123455',
            ShippingCountry = 'Poland',
            Beschaeftigte__c = '5-9',
            Branche_NACE__c = 'Manufacturing',
            Web_form_password__c = 'password123'
        );   
        insert newAccount;
    }


    private static void createSubAccount() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Account' LIMIT 1];
        newSubAccount = new Account(
            RecordTypeId = rt.Id,
            Name = 'test subAccount',
            BillingStreet = 'subAccount street',
            BillingCity = 'Warsaw',
            BillingPostalCode = '123455',
            BillingCountry = 'Poland',
            ParentId = newAccount.Id
        );

        insert newSubAccount;
    }


    private static void createOpportunity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
            RecordTypeId = rt.Id,
            Name = 'test opportunity',
            Umsatz__c = '123',
            Anzahl_der_Karten__c = 123,
            Requested_monthly_Company_Credit_Spend__c = 12345,
            AccountId = newAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(14),
            Data_Protection_Act_1998__c = true,
            Bevollmaechtigung__c = true,
            AGB_Datenschutzhinweise_Richtigkeit__c = true
        );
        insert newOpportunity;
    }

    private static void createContact() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'AllStar' AND sObjectType = 'Contact' LIMIT 1];
        newContact = new Contact(
            AccountId = newAccount.Id,
            Salutation = 'Mr.',
            Position_Funktion__c = 'CEO',
            FirstName = 'Ivan',
            MiddleName = 'Ivanovich',
            LastName = 'Ivanov',
            Mother_s_maiden_name__c = 'test',
            Email = 'contact@test.com',
            Birthdate = Date.today(),
            AllStar_authorised_signatory__c  = true,
            AllStar_account_administrator__c = false,
            AllStar_UBO__c = true,
            PESEL_Nr__c = '12345',
            Phone = '+48 1234567',
            MailingStreet = 'test street',
            MailingCity = 'test city',
            MailingPostalCode = '123423',
            MailingCountry = 'Poland',
            Country_Text__c = 'Poland'
        );
        insert newContact;
    }
}