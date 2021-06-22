public class CreditFactoryUtils {
    /*******************************************************************************
    *  Name            : createCompanyInfoCreditSystem();
    *  Summary         : Create company info custom setting     
    *  CreatedDate     : 06/03/2018
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCompanyInfoCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CompanyInfo',
            Endpoint__c = 'https://ws1.webservices.nl:443/soap_doclit.php', 
            Username__c = 'travelcardtest_User', 
            Password__c = '12345');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditreformAccount()
    *  Summary         : Creating new Account
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : Account
    ******************************************************************************/
    public static Account doCreateCreditreformAccount() {
        Account account = new Account(Name = 'Kundentestsystem Energie und Wasser AG - BITTE NICHT ÄNDERN', Beschaeftigte__c = 'test', Gruende_fuer_Tankkarten__c = 'test', 
                Type = 'test', BillingStreet = 'Dichterweg 27', ShippingStreet = 'Dichterweg 27', BillingPostalCode = '99423',ShippingPostalCode = '99423', 
                BillingCity = 'Weimar', ShippingCity = 'Weimar', IBAN_des_Zahlungspflichtigen__c = 'test', SWIFT_BIC__c = 'test', Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
                Strasse_und_Hausnummer__c = 'test', Hausnummer_E__c = '27', Gesellschaftsform__c = 'LEFO-DE-11', BillingCountry = 'Germany', BillingCountryCode = 'DE', BillingState = 'Berlin',
                Strasse_E__c = 'Dichterweg', PLZ_E__c = '99423', Ort_E__c = 'Weimar', Bundesland__c = 'test', Steuernummer__c = 'test', Umsatzsteuer_ID__c = 'DE821235454');
        return account;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditsafeAccount()
    *  Summary         : Creating new Account
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : Account
    ******************************************************************************/
    public static Account doCreateCreditsafeAccount() {
        Account account = new Account(Name = 'ADIDAS (U.K.) LIMITED', Beschaeftigte__c = 'test', Gruende_fuer_Tankkarten__c = 'test', Type = 'test', 
                BillingStreet = 'PEPPER 12', ShippingStreet = 'PEPPER 12', BillingPostalCode = 'SK7 5SA',ShippingPostalCode = 'SK7 5SA', Steuernummer__c = '01075951',
                BillingCity = 'STOCKPORT', ShippingCity = 'STOCKPORT', Gesellschaftsform__c = 'Private limited with Share Capital', BillingCountry = 'Germany',
                BillingState = 'Berlin', BillingCountryCode = 'DE', IBAN_des_Zahlungspflichtigen__c = 'test', SWIFT_BIC__c = 'test', Name_Zahlungspflichtigen_Kontoinhaber__c = 'test',
                Strasse_und_Hausnummer__c = 'test', Hausnummer_E__c = '12', Strasse_E__c = 'PEPPER', Bundesland__c = 'test', Ort_E__c = 'STOCKPORT', PLZ_E__c = 'SK7 5SA',
                Umsatzsteuer_ID__c = 'test');
        return account;
    }


    /*******************************************************************************
    *  Name            : doCreateOpportunity(String accountId)
    *  Summary         : Creating new Opportunity
    *  CreatedDate     : 11/11/2016
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity doCreateOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(Name = 'Kundentestsystem', StageName = 'Prospecting', CloseDate = date.today().addDays(+5), AccountId = accountId,
                Product__c = 'test', Anzahl_der_Karten__c = 000, Derzeitige_Zahlungsmethode__c = 'test', Kundensegment__c = 'test',
                Zahlungsziel__c = 'test', Zahlungsziel_Credit__c = 'test', Credit_check_date__c = date.today(),
                Billing_Period_by_Sales__c = true, Zahlungsart__c = 'Banküberweisung', Number_of_cars__c = 10, Number_of_trucks__c = 10, Total_consumption_l_month__c = 2000,
                Name_of_the_payer_Account_holder__c = 'test', SWIFT_BIC__c = 'test', Zahlungsziel_2__c = '30', Rechnungsperiode_2__c = '7');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : doCreateContact(String accountId)
    *  Summary         : Creating new Contact
    *  CreatedDate     : 20/11/2016
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact doCreateContact(String accountId) {
        Contact contact = new Contact(LastName = 'KTO Martina', FirstName = 'Muck', Email = 'jrogers@burlington.com', Phone = '+493362227000', AccountId = accountId, 
                Salutation = 'Herr');
        return contact;
    }
    

    /*******************************************************************************
    *  Name            : createCreditsafeAccount()
    *  Summary         : Creating new Account
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 08/08/2019
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCreditsafeAccount() {
        Account account = new Account(
            Name = 'Testgear B.V.',
            Beschaeftigte__c = 'test',
            Type = 'test',
            BillingStreet = 'Molensingel 10', 
            ShippingStreet = 'Molensingel 10', 
            BillingPostalCode = '2614LB',
            ShippingPostalCode = '2614LB', 
            BillingCity = 'DELFT', 
            ShippingCity = 'DELFT', 
            BillingCountry = 'Netherlands',
            Steuernummer__c = '50260340',
            Umsatzsteuer_ID__c = '123123123',
            Gesellschaftsform__c = 'BV');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeOpportunity(String accountId)
    *  Summary         : Creating new Opportunity
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 01/11//2019
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCreditsafeOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'Testgear B.V.', 
            StageName = 'Prospecting', 
            CloseDate = Date.today(), 
            AccountId = accountId,
            Angebotsdauer__c = '3 Monate',
            Derzeitige_Zahlungsmethode__c = 'test',
            Total_consumption_l_month__c = 2000,
            Zahlungsziel_2__c = '7', 
            Rechnungsperiode_2__c = '7',
            Zahlungsart__c = 'Lastschrift',
            Anzahl_der_Karten__c = 0,
            Direct_Debit_Mandate_Type__c = 'B2B',
            Language_preference__c = 'Dutch',
            IBAN__c = 'NL1234512345',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeContact(String accountId)
    *  Summary         : Creating new Contact
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 08/08/2019
    *  Parameters      : String accountId - Id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCreditsafeContact(String accountId) {
        Contact contact = new Contact(
            LastName = 'Trompert',
            FirstName = 'Eamon Petrus',
            Email = 'test@test.test',
            Phone = '+490614246817',
            AccountId = accountId,
            Salutation = 'Herr');
        return contact;
    }


     /*******************************************************************************
    *  Name            : createCreditsafeOpportunityContactRole(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 13/05/2019
    *  ModifiedDate    : -
    *  Parameters      : String contactId - id of contact, String opportunityId - id of opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCreditsafeOpportunityContactRole(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager',
            IsPrimary = true);
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeAccountMapping()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCreditsafeAccountMapping() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'Creditsafe', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeOpportunityMapping()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 02/04/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCreditsafeOpportunityMapping() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'Creditsafe', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer_Formula__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeCreditSystem()
    *  Summary         : Creating Creditsafe CreditSystem
    *  CreatedDate     : 02/04/2018
    *  ModifiedDate    : 08/08/2019
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCreditsafeCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Creditsafe', 
            Endpoint__c = 'https://connect.creditsafe.com/v1',
            Username__c = 'test@test.test', 
            Password__c = 'test', 
            Supported_Countries__c = 'Netherlands,France,Belgium-FR,Belgium-NL');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditSystem()
    *  Summary         : Creating new CreditSystem
    *  CreatedDate     : 11/11/2016
    *  Parameters      : 
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c doCreateCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(Name = 'test', Endpoint__c = 'https://webservices.creditsafe.com/GlobalData/1.3/MainServiceBasic.svc',
                Username__c = '345013323001', Password__c = '1ppf39vE', API_Key__c = 'CFflt123');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditFactoryAccount()
    *  Summary         : Creating CreditFactoryAccount
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c doCreateCreditFactoryAccount() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(Name = 'Test', Company_Form__c = 'Gesellschaftsform__c', 
                Number_of_employees__c = 'Beschaeftigte__c', Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
                Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', Type__c = 'Type', Tax_Id__c = 'Steuernummer__c', 
                VAT_Number__c = 'Umsatzsteuer_ID__c', Business_Street__c = 'BillingStreet', City__c = 'BillingCity', Country__c = 'BillingCountry', 
                Federal_State__c = 'BillingState', Postal_Code__c = 'BillingPostalCode', House_Number__c = 'Hausnummer_E__c', IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
                Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditFactoryOpportunity()
    *  Summary         : Creating CreditFactoryOpportunity
    *  CreatedDate     : 15/11/2016
    *  Parameters      : 
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c doCreateCreditFactoryOpportunity() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(Name = 'Test', Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
                Number_of_employees__c = 'Zahl_der_Mitarbeiter__c', Year_of_foundation__c = 'Gruendungsjahr__c', Billing_Period__c = 'Rechnungsperiode__c', 
                Credit_Check_Date__c = 'Credit_check_date__c', Credit_Decision__c = 'Kredit_Entscheidung__c', Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
                Product__c = 'Product__c', Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c', Payment_Method__c = 'Zahlungsart__c', Turn_Over__c = 'Umsatz__c', 
                Credit_System_Number__c = 'Credit_System_Number__c', Payment_Terms__c = 'Zahlungsziel__c', Risk_Category__c = 'Risk_Category__c', 
                Details_Correct__c = 'Angaben_korrekt__c', Financials__c = 'Financials__c', Processed_by__c = 'bearbeitet_von__c', 
                Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', Customer_Segment__c = 'Kundensegment__c', Number_of_Cards__c = 'Anzahl_der_Karten__c', 
                Credit_System_Rating__c = 'Credit_System_Rating__c', Buffer__c = 'Buffer_Formula__c', Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
                Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c', Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c', IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
                SWIFT_BIC__c = 'SWIFT_BIC__c', Max_Credit_Limit__c = 'Max_Credit_Limit__c', CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditBlackListCompany()
    *  Summary         : Creating Credit_Black_List_Company__c
    *  CreatedDate     : 25/11/2016
    *  Parameters      : 
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c doCreateCreditBlackListCompany(String accountName) {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(Customer_Full_Name__c = accountName);
        return blackList;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditreformReport()
    *  Summary         : create Credit_Factory_Report__c
    *  CreatedDate     : 24/10/2017
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c doCreateCreditreformReport() {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = '123123', Class_Rating__c = '1', Legal_Form__c = 'AG', Company_Id__c = '123',
                Name = 'KUNDENTESTSYSTEM ENERGIE UND WASSER AG - BITTE NICHT ÄNDERN', Street__c = 'DICHTERWEG', 
                Name__c = 'KUNDENTESTSYSTEM ENERGIE UND WASSER AG - BITTE NICHT ÄNDERN',City__c = 'WEIMAR', Housenumber__c = '27', 
                Postcode__c = '99423');
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : doCreateCreditreformReportEmployee()
    *  Summary         : create Credit_Factory_Report_Employee__c
    *  CreatedDate     : 24/10/2017
    *  ModifiedDate    : 24/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c doCreateCreditreformReportEmployee() {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Martina');
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeReport()
    *  Summary         : create Credit_Factory_Report__c
    *  CreatedDate     : 24/10/2017
    *  ModifiedDate    : 12/08/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCreditsafeReport() {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Class_Rating__c = '5', 
                Legal_Form__c = 'BV',
                Name = 'Testgear B.V.', 
                Name__c = 'Testgear B.V.', 
                Street__c = 'Molensingel', 
                City__c = 'DELFT', 
                Housenumber__c = '10', 
                Postcode__c = '2614LB', 
                Email__c = 'test@test.te', 
                Date_of_Foundation__c = '2010-10-10',
                Tax_Id__c = '50260340');
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : createCreditsafeReportEmployee()
    *  Summary         : create Credit_Factory_Report_Employee__c
    *  CreatedDate     : 24/10/2017
    *  ModifiedDate    : 12/08/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCreditsafeReportEmployee() {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Eamon Petrus Trompert',
            Company_Id__c = 'NL001-X-634214960000',
            Company_Type__c = 'Ultimate Parent',
            Company_Role__c = 'ShareHolder');
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCofaceAccount()
    *  Summary         : Create test Account.
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 04/04/2019
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCofaceAccount() {
        Account account = new Account(
            Name = 'Hild Ingatlanbefektető Kft.', 
            BillingStreet = 'Lajos utca 74-76.',
            ShippingStreet = 'Lajos utca 74-76.',
            BillingPostalCode = '1036',
            ShippingPostalCode = '1036',
            BillingCity = 'BUDAPEST',
            ShippingCity = 'BUDAPEST',
            BillingCountry = 'Hungary',
            BillingCountryCode = 'HU',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Limited Liability Company',
            Steuernummer__c = '13373344-2-41',
            Umsatzsteuer_ID__c = 'HU13373344',
            HR_Abteilung_HRA_HRB_und_HR_Nummer__c = '0109731931');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCofaceOpportunity(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 01/11/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCofaceOpportunity(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'MVM MAGYAR VILLAMOS MUVEK ZART',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Zahlungsziel_2__c = '7',
            Rechnungsperiode_2__c = '7',
            Total_consumption_l_month__c = 100,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Anzahl_der_Karten__c = 0,
            Zahlungsart__c = 'Lastschrift',
            Language_preference__c = 'Hungarian',
            IBAN__c = 'HU1234512345',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCofaceContact(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 06/03/2018
    *  ModifiedDate    : 13/05/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCofaceContact(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Tibor',
            FirstName = 'BIRÓ Balázs',
            AccountId = accountId,
            MailingCountry = 'Hungary',
            MailingCountryCode = 'HU',
            Phone = '123123123',
            Email = 'balazstibor@test.com');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCofaceCreditSystem()
    *  Summary         : Create test Credit System for Coface.    
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCofaceCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Coface',
            Endpoint__c = 'https://test.cofacecentraleurope.com/iconwebservices', 
            Username__c = 'Petr.Cermak@fleetcor.eu', 
            Password__c = 'Fleetcor2018',
            Supported_Countries__c = 'Hungary');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCofaceAccountMapping()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCofaceAccountMapping() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'Coface', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCofaceOpportunityMapping()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCofaceOpportunityMapping() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'Coface',
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer_Formula__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCofaceBlackList()
    *  Summary         : Create test Black list for Coface.
    *  CreatedDate     : 07/03/2018
    *  ModifiedDate    : 07/03/2018
    *  Parameters      : -
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCofaceBlackList() {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = 'Test Black List');
        return blackList;
    }

    /*******************************************************************************
    *  Name            : createCofaceOpportunityContactRole(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 08/03/2017
    *  ModifiedDate    : 13/05/2019
    *  Parameters      : String contactId - id of contact, String opportunityId - id of opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCofaceOpportunityContactRole(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager',
            IsPrimary = true);
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCofaceReport()
    *  Summary         : create Credit_Factory_Report__c
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 05/04/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCofaceReport() {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Credit_System_Number__c = '123123', 
                Tax_Id__c = '13373344-2-41',
                Class_Rating__c = '1', 
                Legal_Form__c = 'Limited Liability Company', 
                VAT_Number__c = 'HU13373344',
                Trade_Register_Number__c = '0109731931',
                Company_Id__c = '123',
                Name = 'Hild Ingatlanbefektető Korlátolt Felelősségű Társaság', 
                Name__c = 'Hild Ingatlanbefektető Korlátolt Felelősségű Társaság', 
                Trade_Name__c = 'Hild Ingatlanbefektető Kft.',
                Street__c = 'Lajos utca', 
                City__c = 'BUDAPEST', 
                Housenumber__c = '74-76.', 
                Postcode__c = '1036',
                Request_Status__c = 'OK',
                Obligation_Overdue__c = false,
                Date_of_Foundation__c = '10.10.2010',
                Credit_Limit__c = '3000000',
                Profit_loss_last_year__c = '31000000',
                Profit_loss_year_before_last__c = '31000000',
                Turn_Over_last_year__c = '31000000');
        return creditReport;
    }


    /*******************************************************************************
    *  Name            : createCofaceReportEmployee()
    *  Summary         : create Credit_Factory_Report_Employee__c
    *  CreatedDate     : 08/03/2018
    *  ModifiedDate    : 08/03/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCofaceReportEmployee() {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'BIRÓ Balázs Tibor');
        return creditReportEmployee;
    }
    
    
    /*******************************************************************************
    *  Summary         : create CF_Order_Notifications__c object
    *  Created         : 25/03/2020
    *  Parameters      : -
    *  Returns         : order notification
    ******************************************************************************/
    public static CF_Order_Notifications__c createOrderNotificationHU() {
        CF_Order_Notifications__c notification = new CF_Order_Notifications__c();
        notification.Name = 'Hungary';
        notification.Active__c = true;
        notification.Email__c = 'test@test.com';
        return notification;
    }


    /*******************************************************************************
    *  Name            : createCreditReformAccountAT()
    *  Summary         : Create test Account.
    *  CreatedDate     : 01/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCreditReformAccountAT() {
        Account account = new Account(
            Name = 'AT Kundentestsystem Aktiengesellschaft - BITTE NICHT ÄNDERN', 
            BillingStreet = 'Salzstrasse 46',
            ShippingStreet = 'Salzstrasse 46',
            BillingPostalCode = '2560',
            ShippingPostalCode = '2560',
            BillingCity = 'Berndorf',
            ShippingCity = 'Berndorf',
            BillingCountry = 'Austria',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Gesellschaft mit beschränkter Haftung',
            Steuernummer__c = '3186478',
            Umsatzsteuer_ID__c = 'ATU69772169');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityAT(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 01/10/2018
    *  ModifiedDate    : 01/11/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCreditreformOpportunityAT(String accountId) {
        Opportunity opportunity = new Opportunity(
                Name = 'AT Kundentestsystem Aktiengesellschaft - BITTE NICHT ÄNDERN',
                AccountId = accountId,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Angebotsdauer__c = '3 Monate',
                Total_consumption_l_month__c = 2000,
                Derzeitige_Zahlungsmethode__c = 'Barzahlung',
                Zahlungsziel_2__c = '30',
                Rechnungsperiode_2__c = '7',
                Zahlungsart__c = 'Lastschrift',
                Anzahl_der_Karten__c = 0,
                Sec_Channel__c = 'JITB',
                Direct_Debit_Mandate_Type__c = 'B2B',
                Language_preference__c = 'German',
                IBAN__c = 'AT1234512345',
                SWIFT_BIC__c = 'AA12341234',
                Requested_SWIFT_BIC__c = 'AA12341234',
                Product__c = 'Sales no fee promo Feb 2016',
                Home_Station__c = 'test',
                ESI__c = 'test');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformContactAT(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 01/10/2018
    *  ModifiedDate    : 14/05/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCreditreformContactAT(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Ochsenkott KTO',
            FirstName = 'Oswald',
            AccountId = accountId, 
            Phone = '+49123123123',
            Email = 'OswaldOchsenkott@test.com');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCreditreformCreditSystemAT()
    *  Summary         : Create test Credit System for Creditreform AT.    
    *  CreatedDate     : 01/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCreditreformCreditSystemAT() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CreditReformAT',
            Endpoint__c = 'https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', 
            Username__c = '345013323001', 
            Password__c = '1ppf39vE',
            API_Key__c = 'CFflt123',
            Supported_Countries__c = 'Austria');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCreditreformAccountMappingAT()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCreditreformAccountMappingAT() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'CreditreformAT', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCrifOpportunityMappingAT()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCreditreformOpportunityMappingAT() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'CreditreformAT', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer_Formula__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformBlackListAT()
    *  Summary         : Create test Black list for Crif.
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountName - name of account
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCreditreformBlackListAT(String accountName) {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = accountName,
            Customer_Id__c = 'AT');
        return blackList;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityContactRoleAT(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : 14/05/2019
    *  Parameters      : String contactId - id of Сontact, String opportunityId - id of Щpportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCreditreformOpportunityContactRoleAT(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager',
            IsPrimary = true);
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCreditreformReportAT()
    *  Summary         : Create Credit Factory Report
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : String opportunityId - id of parent Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCreditreformReportAT(String opportunityId) {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Class_Rating__c = '1', Legal_Form__c = 'Gesellschaft mit beschränkter Haftung', Company_Id__c = '123',
                Name = 'AT Kundentestsystem Aktiengesellschaft - BITTE NICHT ÄNDERN',
                Name__c = 'AT Kundentestsystem Aktiengesellschaft - BITTE NICHT ÄNDERN', Street__c = 'Salzstrasse', City__c = 'Berndorf', 
                Housenumber__c = '46', Postcode__c = '2560');
        return creditReport;
    }

    /*******************************************************************************
    *  Name            : createCreditreformReportEmployeeAT()
    *  Summary         : Create Credit Factory Report Employee
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String reportId - id of parent Credit Factory Report
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCreditreformReportEmployeeAT(String reportId) {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Oswald Ochsenkott KTO',
            Credit_Factory_Report__c = reportId);
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectAccountCH()
    *  Summary         : Create test Account.
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCrediconnectAccountCH() {
        Account account = new Account(
            Name = 'TesT AG Schweiz', 
            BillingStreet = 'Bösch 63',
            ShippingStreet = 'Bösch 63',
            BillingPostalCode = '6331',
            ShippingPostalCode = '6331',
            BillingCity = 'Hünenberg',
            ShippingCity = 'Hünenberg',
            BillingCountry = 'Switzerland-DE',
            BillingCountryCode = 'CHDE',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Aktiengesellschaft',
            Steuernummer__c = 'CH17030143616',
            Umsatzsteuer_ID__c = 'CHE110477663');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectOpportunityCH(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : 01/11/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCrediconnectOpportunityCH(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'TesT AG Schweiz',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 1000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsart__c = 'Lastschrift',
            Anzahl_der_Karten__c = 0,
            Sec_Channel__c = 'JITB',
            Direct_Debit_Mandate_Type__c = 'B2B',
            Language_preference__c = 'German',
            IBAN__c = 'CH1234512345',
            SWIFT_BIC__c = 'AA12341234', 
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectContactCH(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : 14/05/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCrediconnectContactCH(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            FirstName = 'Therese',
            LastName = 'Havemann',
            AccountId = accountId,
            MailingCountry = 'Switzerland-DE',
            MailingCountryCode = 'CHDE',
            Phone = '1234123414',
            Email = 'ThereseHavemann@test.com');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectContactRoleCH(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : 14/05/2019
    *  Parameters      : String contactId - id of Сontact, String opportunityId - id of Щpportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCrediconnectContactRoleCH(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager',
            IsPrimary = true);
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectCreditSystemCH()
    *  Summary         : Create test Credit System for Crediconnect CH.    
    *  CreatedDate     : 12/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCrediconnectCreditSystemCH() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CrediConnectCH',
            Endpoint__c = 'https://webservice.crediconnect.ch/V2/03/CrediConnect.svc/basic', 
            Username__c = 'VENT4CC20_CONNECT', 
            Password__c = 'CON4CC20VENT99',
            Supported_Countries__c = 'Switzerland-DE, Switzerland-AT, Switzerland-IT');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectAccountMappingCH()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCrediconnectAccountMappingCH() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'CrediconnectCH', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectOpportunityMappingCH()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCrediconnectOpportunityMappingCH() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'CrediconnectCH', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer_Formula__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectBlackListCH()
    *  Summary         : Create test Black list for Crif.
    *  CreatedDate     : 15/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountName - name of account
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCrediconnectBlackListCH(String accountName) {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = accountName,
            Customer_Id__c = 'CH');
        return blackList;
    }


    /*******************************************************************************
    *  Name            : createCrediconnectReportCH()
    *  Summary         : Create Credit Factory Report
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : String opportunityId - id of parent Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCrediconnectReportCH(String opportunityId) {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Class_Rating__c = '4', Legal_Form__c = 'Aktiengesellschaft', Company_Id__c = '123',
                Name = 'TesT AG Schweiz', Name__c = 'TesT AG Schweiz', Street__c = 'Bösch', City__c = 'Hünenberg', 
                Housenumber__c = '63', Postcode__c = '6331', Phone__c = '0417856010', 
                Date_of_Foundation__c = CreditFactoryUtilities.returnCurrentDate());
        return creditReport;
    }

    /*******************************************************************************
    *  Name            : createCrediconnectReportEmployeeCH()
    *  Summary         : Create Credit Factory Report Employee
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : -
    *  Parameters      : String reportId - id of parent Credit Factory Report
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCrediconnectReportEmployeeCH(String reportId) {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Therese Havemann',
            Credit_Factory_Report__c = reportId);
        return creditReportEmployee;
    }


    /*******************************************************************************
    *  Name            : createCreditReformAccountLU()
    *  Summary         : Create test Account.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Account
    ******************************************************************************/
    public static Account createCreditReformAccountLU() {
        Account account = new Account(
            Name = 'LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN', 
            BillingStreet = 'Bld. Pierre Rot 169',
            ShippingStreet = 'Bld. Pierre Rot 169',
            BillingPostalCode = '1543',
            ShippingPostalCode = '1543',
            BillingCity = 'Luxembourg',
            ShippingCity = 'Luxembourg',
            BillingCountry = 'Luxembourg',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'Gesellschaft mit beschränkter Haftung',
            Steuernummer__c = '20132204773',
            Umsatzsteuer_ID__c = 'LU26090041');
        return account;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityLU(String accountId)
    *  Summary         : Create test Opportuinty.    
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : 23/04/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Opportunity
    ******************************************************************************/
    public static Opportunity createCreditreformOpportunityLU(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 2000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '7', 
            Rechnungsperiode_2__c = '7',
            Zahlungsart__c = 'Lastschrift',
            Anzahl_der_Karten__c = 0,
            Sec_Channel__c = 'JITB',
            Direct_Debit_Mandate_Type__c = 'B2B',
            Language_preference__c = 'German',
            IBAN__c = 'LU1234512345',
            SWIFT_BIC__c = 'AA12341234',
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test');
        return opportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformContactLU(String accountId)
    *  Summary         : Create test Contact.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : 14/05/2019
    *  Parameters      : String accountId - id of related Account
    *  Returns         : Contact
    ******************************************************************************/
    public static Contact createCreditreformContactLU(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Auteil - KTO',
            FirstName = 'Alain',
            AccountId = accountId,
            Phone = '+491234123412',
            Email = 'AlainAuteil@test.com');
        return contact;
    }


    /*******************************************************************************
    *  Name            : createCreditreformCreditSystemLU()
    *  Summary         : Create test Credit System for Creditreform AT.    
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createCreditreformCreditSystemLU() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'CreditReformLU',
            Endpoint__c = 'https://ktu.onlineservice.creditreform.de:443/webservice/0520-0018/soap12/messages.wsdl', 
            Username__c = '345013323001', 
            Password__c = '1ppf39vE',
            API_Key__c = 'CFflt123',
            Supported_Countries__c = 'Luxembourg');
        return creditSystem;
    }


    /*******************************************************************************
    *  Name            : createCreditreformAccountMappingLU()
    *  Summary         : Create test mapping for Account.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Account__c
    ******************************************************************************/
    public static Credit_Factory_Account__c createCreditreformAccountMappingLU() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'CreditreformLU', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityMappingLU()
    *  Summary         : Create test mapping for Opportunity.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Credit_Factory_Opportunity__c
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createCreditreformOpportunityMappingLU() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'CreditreformLU', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer_Formula__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Name            : createCreditreformBlackListLU()
    *  Summary         : Create test Black list for Creditreform.
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String accountName - name of account
    *  Returns         : Credit_Black_List_Company__c
    ******************************************************************************/
    public static Credit_Black_List_Company__c createCreditreformBlackListLU(String accountName) {
        Credit_Black_List_Company__c blackList = new Credit_Black_List_Company__c(
            Customer_Full_Name__c = accountName,
            Customer_Id__c = 'LU');
        return blackList;
    }


    /*******************************************************************************
    *  Name            : createCreditreformOpportunityContactRoleLU(String contactId, String opportunityId)
    *  Summary         : Create test Opportunity Cotnact Role.    
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : 14/05/2019
    *  Parameters      : String contactId - id of Сontact, String opportunityId - id of Opportunity
    *  Returns         : OpportunityContactRole
    ******************************************************************************/
    public static OpportunityContactRole createCreditreformOpportunityContactRoleLU(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager',
            IsPrimary = true);
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Name            : createCreditreformReportLU()
    *  Summary         : Create Credit Factory Report
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : 16/01/2019
    *  Parameters      : String opportunityId - id of parent Opportunity
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report__c createCreditreformReportLU(String opportunityId) {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
                Class_Rating__c = '1', Legal_Form__c = 'Gesellschaft mit beschränkter Haftung', Company_Id__c = '123',
                Name = 'LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN',
                Name__c = 'LU - Kundentestsystem Group SA - BITTE NICHT ÄNDERN', Street__c = 'Bld. Pierre Rot', City__c = 'Luxembourg', 
                Housenumber__c = '169', Postcode__c = '1543');
        return creditReport;
    }

    /*******************************************************************************
    *  Name            : createCreditreformReportEmployeeLU()
    *  Summary         : Create Credit Factory Report Employee
    *  CreatedDate     : 16/11/2018
    *  ModifiedDate    : -
    *  Parameters      : String reportId - id of parent Credit Factory Report
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createCreditreformReportEmployeeLU(String reportId) {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Alain Auteil - KTO',
            Credit_Factory_Report__c = reportId);
        return creditReportEmployee;
    }
    
    
    /*******************************************************************************
    *  Summary         : Create test Account object.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : account
    ******************************************************************************/
    public static Account createAccountDE() {
        Account account = new Account(
            Name = 'Buchverlagsgesellschaft Druck mbH',
            BillingStreet = 'Schillerstr. 52-60',
            ShippingStreet = 'Schillerstr. 52-60',
            BillingPostalCode = '60313',
            ShippingPostalCode = '60313',
            BillingCity = 'Frankfurt am Main',
            ShippingCity = 'Frankfurt am Main',
            BillingCountry = 'Germany',
            Type = 'Customer',
            Beschaeftigte__c = '1-4',
            Gesellschaftsform__c = 'AG',
            Umsatzsteuer_ID__c = 'DE123547899');
        return account;
    }


    /*******************************************************************************
    *  Summary         : Create test Opportuinty object
    *  CreatedDate     : 04/03/2020
    *  Parameters      : accountId - id of related Account
    *  Returns         : opportunity
    ******************************************************************************/
    public static Opportunity createOpportunityDE(String accountId) {
        Opportunity opportunity = new Opportunity(
            Name = 'Buchverlagsgesellschaft Druck mbH',
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Angebotsdauer__c = '3 Monate',
            Total_consumption_l_month__c = 2000,
            Derzeitige_Zahlungsmethode__c = 'Barzahlung',
            Zahlungsziel_2__c = '7', 
            Rechnungsperiode_2__c = '7',
            Anzahl_der_Karten__c = 0,
            Zahlungsart__c = 'Lastschrift',
            Direct_Debit_Mandate_Type__c = 'B2B',
            Language_preference__c = 'German',
            IBAN__c = 'DE1234512345',
            SWIFT_BIC__c = 'AA12341234', 
            Requested_SWIFT_BIC__c = 'AA12341234',
            Product__c = 'Sales no fee promo Feb 2016',
            Home_Station__c = 'test',
            ESI__c = 'test',
            Sec_Channel__c = 'Inbound');
        return opportunity;
    }


    /*******************************************************************************
    *  Summary         : Create test Contact object
    *  CreatedDate     : 04/03/2020
    *  Parameters      : accountId - id of related Account
    *  Returns         : contact
    ******************************************************************************/
    public static Contact createContactDE(String accountId) {
        Contact contact = new Contact(
            Salutation = 'Herr',
            LastName = 'Ottersbach',
            FirstName = 'Cornelius',
            AccountId = accountId,
            Phone = '123123412345');
        return contact;
    }
    
    
    /*******************************************************************************
    *  Summary         : Create test Opportunity Contact role object.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : contactId - id of contact, 
                         opportunityId - id of opportunity
    *  Returns         : contact role
    ******************************************************************************/
    public static OpportunityContactRole createOpportunityContactRoleDE(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = opportunityId,
            ContactId = contactId,
            Role = 'Fleet manager',
            IsPrimary = true);
        return opportunityContactRole;
    }


    /*******************************************************************************
    *  Summary         : Create test mapping for Account object.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : account mapping
    ******************************************************************************/
    public static Credit_Factory_Account__c createSchufaAccountMapping() {
        Credit_Factory_Account__c creditFactoryAccount = new Credit_Factory_Account__c(
            Name = 'Schufa', 
            Company_Form__c = 'Gesellschaftsform__c', 
            Number_of_employees__c = 'Beschaeftigte__c', 
            Bussines_Street_and_House_Number__c = 'Strasse_und_Hausnummer__c', 
            Reason_for_fuel_cards__c = 'Gruende_fuer_Tankkarten__c', 
            Type__c = 'Type', 
            Tax_Id__c = 'Steuernummer__c', 
            VAT_Number__c = 'Umsatzsteuer_ID__c', 
            Business_Street__c = 'BillingStreet', 
            City__c = 'BillingCity', 
            Country__c = 'BillingCountry', 
            Federal_State__c = 'BillingState', 
            Postal_Code__c = 'BillingPostalCode', 
            House_Number__c = 'Hausnummer_E__c', 
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            Payer_Owner_Name__c = 'Name_Zahlungspflichtigen_Kontoinhaber__c', 
            SWIFT_BIC__c = 'SWIFT_BIC__c');
        return creditFactoryAccount;
    }


    /*******************************************************************************
    *  Summary         : Create test mapping for Opportunity objecet.
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : opportunity mapping
    ******************************************************************************/
    public static Credit_Factory_Opportunity__c createSchufaOpportunityMapping() {
        Credit_Factory_Opportunity__c creditFactoryOpportunity = new Credit_Factory_Opportunity__c(
            Name = 'Schufa', 
            Credit_System_Limit__c = 'Credit_System_Recommended_Limit__c',
            Number_of_employees__c = 'Zahl_der_Mitarbeiter__c',
            Year_of_foundation__c = 'Gruendungsjahr__c',
            Billing_Period__c = 'Rechnungsperiode__c', 
            Credit_Check_Date__c = 'Credit_check_date__c',
            Credit_Decision__c = 'Kredit_Entscheidung__c',
            Security_Level__c = 'Security_level_H_he_der_Sicherheit__c', 
            Product__c = 'Product__c',
            Current_Payment_Method__c = 'Derzeitige_Zahlungsmethode__c',
            Payment_Method__c = 'Zahlungsart__c',
            Turn_Over__c = 'Umsatz__c', 
            Credit_System_Number__c = 'Credit_System_Number__c',
            Payment_Terms__c = 'Zahlungsziel__c',
            Risk_Category__c = 'Risk_Category__c', 
            Details_Correct__c = 'Angaben_korrekt__c', 
            Financials__c = 'Financials__c', 
            Processed_by__c = 'bearbeitet_von__c', 
            Fuel_consumption_l_month__c = 'Total_consumption_l_month__c', 
            Customer_Segment__c = 'Kundensegment__c',
            Number_of_Cards__c = 'Anzahl_der_Karten__c', 
            Credit_System_Rating__c = 'Credit_System_Rating__c',
            Buffer__c = 'Buffer_Formula__c',
            Monthly_Volume_Currency__c = 'Auftragsvolumen__c',
            Payment_Terms_Credit__c = 'Zahlungsziel_Credit__c',
            Payer_Owner_Name__c = 'Name_of_the_payer_Account_holder__c',
            IBAN__c = 'IBAN_des_Zahlungspflichtigen__c',
            SWIFT_BIC__c = 'SWIFT_BIC__c',
            Max_Credit_Limit__c = 'Max_Credit_Limit__c',
            CF_Credit_Limit__c = 'CF_Credit_Limit__c');
        return creditFactoryOpportunity;
    }


    /*******************************************************************************
    *  Summary         : Create test Credit System object for Schufa.    
    *  CreatedDate     : 04/03/2020
    *  Parameters      : -
    *  Returns         : CreditSystem__c
    ******************************************************************************/
    public static CreditSystem__c createSchufaCreditSystem() {
        CreditSystem__c creditSystem = new CreditSystem__c(
            Name = 'Schufa',
            Endpoint__c = 'https://kycnow.test.fino.cloud/api/v1', 
            Username__c = 'fleetcor_eu', 
            Password__c = 'f0503e6c-c180-49b2-9f8a-4d9fcdd1b262',
            Supported_Countries__c = 'Germany');
        return creditSystem;
    }


    /*******************************************************************************
    *  Summary         : create Credit_Factory_Report__c
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public static Credit_Factory_Report__c createSchufaReport() {
        Credit_Factory_Report__c creditReport = new Credit_Factory_Report__c(
            Class_Rating__c = '1', 
            Name = 'Buchverlagsgesellschaft Druck mbH', 
            Name__c = 'Buchverlagsgesellschaft Druck mbH', 
            Street__c = 'Schillerstr. 52-60', 
            City__c = 'Frankfurt am Main', 
            Postcode__c = '60313', 
            Email__c = 'test@test.te', 
            Date_of_Foundation__c = '10.10.2010',
            Vat_Number__c = 'DE123547899');
        return creditReport;
    }


    /*******************************************************************************
    *  Summary         : create Credit_Factory_Report_Employee__c
    *  CreatedDate     : 12/03/2020
    *  Parameters      : -
    *  Returns         : -
    ******************************************************************************/
    public static Credit_Factory_Report_Employee__c createSchufaReportEmployee() {
        Credit_Factory_Report_Employee__c creditReportEmployee = new Credit_Factory_Report_Employee__c(
            Name = 'Cornelius Ottersbach');
        return creditReportEmployee;
    }
    
    
    /*******************************************************************************
    *  Summary         : create CF_Order_Notifications__c object
    *  Created         : 16/03/2020
    *  Parameters      : -
    *  Returns         : order notification
    ******************************************************************************/
    public static CF_Order_Notifications__c createOrderNotificationDE() {
        CF_Order_Notifications__c notification = new CF_Order_Notifications__c();
        notification.Name = 'Germany';
        notification.Active__c = true;
        notification.Email__c = 'test@test.com';
        return notification;
    }


    /*******************************************************************************
    *  Name            : сreateCreditSystemSalesProfile()
    *  Summary         : Create Credit_Factory_User_Profile__c
    *  CreatedDate     : 02/10/2018
    *  ModifiedDate    : 11/11/2019
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static Credit_Factory_User_Profile__c createCreditFactoryUserProfile() {
        Credit_Factory_User_Profile__c creditFactoryUserProfile = new Credit_Factory_User_Profile__c(Name = 'System Administrator');
        return creditFactoryUserProfile;
    }


    /*******************************************************************************
    *  Name            : createTask(String opportunityId)
    *  Summary         : Create task on Opportunity    
    *  CreatedDate     : 07/06/2018
    *  ModifiedDate    : -
    *  Parameters      : String opportunityId - Id of related Opportunity
    *  Returns         : Task
    ******************************************************************************/
    public static Task createTask(String opportunityId) {
        Task task = new Task(
            WhatId = opportunityId);
        return task;
    }


    /*******************************************************************************
    *  Name            : createCreditFactorySoqlFieldsList()
    *  Summary         : Create set of fields to select    
    *  CreatedDate     : 02/05/2018
    *  ModifiedDate    : 11/12/2019
    *  Parameters      : -
    *  Returns         : List<CreditFactory_Opportunity_SOQL__c>
    ******************************************************************************/
    public static List<CreditFactory_Opportunity_SOQL__c> createCreditFactorySoqlFieldsList() {
        List<CreditFactory_Opportunity_SOQL__c> creditFactorySoqlFieldsList = new List<CreditFactory_Opportunity_SOQL__c>();
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Angaben_korrekt__c', Field_Name__c = 'Angaben_korrekt__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Anzahl_der_Karten__c', Field_Name__c = 'Anzahl_der_Karten__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Auftragsvolumen__c', Field_Name__c = 'Auftragsvolumen__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'bearbeitet_von__c', Field_Name__c = 'bearbeitet_von__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Buffer__c', Field_Name__c = 'Buffer_Formula__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'CF_Credit_Limit__c', Field_Name__c = 'CF_Credit_Limit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'CF_Stage__c', Field_Name__c = 'CF_Stage__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_check_date__c', Field_Name__c = 'Credit_check_date__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_System_Id__c', Field_Name__c = 'Credit_System_Id__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_System_Number__c', Field_Name__c = 'Credit_System_Number__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_System_Rating__c', Field_Name__c = 'Credit_System_Rating__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_System_Recommended_Limit__c', Field_Name__c = 'Credit_System_Recommended_Limit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Custom_PIN__c', Field_Name__c = 'Custom_PIN__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Derzeitige_Zahlungsmethode__c', Field_Name__c = 'Derzeitige_Zahlungsmethode__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Einwilligung_Lastschriftverfahren__c', Field_Name__c = 'Einwilligung_Lastschriftverfahren__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Financials__c', Field_Name__c = 'Financials__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Gruendungsjahr__c', Field_Name__c = 'Gruendungsjahr__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'IBAN__c', Field_Name__c = 'IBAN__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Kredit_Entscheidung__c', Field_Name__c = 'Kredit_Entscheidung__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Kundensegment__c', Field_Name__c = 'Kundensegment__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Last_CF_Errors__c', Field_Name__c = 'Last_CF_Errors__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Max_Credit_Limit__c', Field_Name__c = 'Max_Credit_Limit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Name', Field_Name__c = 'Name'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Name_of_the_payer_Account_holder__c', Field_Name__c = 'Name_of_the_payer_Account_holder__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Probability', Field_Name__c = 'Probability'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Product__c', Field_Name__c = 'Product__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Rechnungsperiode_2__c', Field_Name__c = 'Rechnungsperiode_2__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Rechnungsperiode__c', Field_Name__c = 'Rechnungsperiode__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Risk_Category__c', Field_Name__c = 'Risk_Category__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Security_level_H_he_der_Sicherheit__c', Field_Name__c = 'Security_level_H_he_der_Sicherheit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'SEPA_Request_Approved__c', Field_Name__c = 'SEPA_Request_Approved__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'StageName', Field_Name__c = 'StageName'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'SWIFT_BIC__c', Field_Name__c = 'SWIFT_BIC__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Requested_SWIFT_BIC__c', Field_Name__c = 'Requested_SWIFT_BIC__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Total_consumption_l_month__c', Field_Name__c = 'Total_consumption_l_month__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Umsatz__c', Field_Name__c = 'Umsatz__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Updated_From_Credit_Factory__c', Field_Name__c = 'Updated_From_Credit_Factory__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahlungsart__c', Field_Name__c = 'Zahlungsart__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahlungsziel_2__c', Field_Name__c = 'Zahlungsziel_2__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahlungsziel_Credit__c', Field_Name__c = 'Zahlungsziel_Credit__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahlungsziel__c', Field_Name__c = 'Zahlungsziel__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Zahl_der_Mitarbeiter__c', Field_Name__c = 'Zahl_der_Mitarbeiter__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Send_SEPA_approval_link__c', Field_Name__c = 'Send_SEPA_approval_link__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Profit_loss_last_year__c', Field_Name__c = 'Profit_loss_last_year__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Profit_loss_year_before_last__c', Field_Name__c = 'Profit_loss_year_before_last__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Turnover_last_year__c', Field_Name__c = 'Turnover_last_year__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'DocuSign_Status__c', Field_Name__c = 'DocuSign_Status__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Contact_Role_Confirmation_Call__c', Field_Name__c = 'Contact_Role_Confirmation_Call__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'E2E_Form_of_Business__c', Field_Name__c = 'E2E_Form_of_Business__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Sec_Channel__c', Field_Name__c = 'Sec_Channel__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'e_Invoicing_PDF__c', Field_Name__c = 'e_Invoicing_PDF__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Papierrechnung__c', Field_Name__c = 'Papierrechnung__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'CF_Full_Report_Date__c', Field_Name__c = 'CF_Full_Report_Date__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Non_fuel_exposure__c', Field_Name__c = 'Non_fuel_exposure__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Direct_Debit_Mandate_Type__c', Field_Name__c = 'Direct_Debit_Mandate_Type__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'LeadSource', Field_Name__c = 'LeadSource'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Total_consumption_per_card__c', Field_Name__c = 'Total_consumption_per_card__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Credit_Stage__c', Field_Name__c = 'Credit_Stage__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Monthly_Volume_per_card__c', Field_Name__c = 'Monthly_Volume_per_card__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Visitor_Id__c', Field_Name__c = 'Visitor_Id__c'));
            creditFactorySoqlFieldsList.add(new CreditFactory_Opportunity_SOQL__c(
                Name = 'Owner.Name', Field_Name__c = 'Owner.Name'));
        return creditFactorySoqlFieldsList;
    }

    /*******************************************************************************
    *  Name            : createLexisNexisSettings()
    *  Summary         : Create LexisNexis custom settings
    *  CreatedDate     : 03/05/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static LexisNexis_Settings__c createLexisNexisSettings() {
        LexisNexis_Settings__c lexisNexisSettings = new LexisNexis_Settings__c(
            Name = 'Production',
            Active__c = false,
            Endpoint__c = 'https://test.com',
            User_Name__c = 'test',
            Password__c = 'test');
        return lexisNexisSettings;
    }
    

    /*******************************************************************************
    *  Name            : returnSolvencySettingsCH()
    *  Summary         : Return settings with mapping between solvency and rating
    *  CreatedDate     : 14/06/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Solvency__c
    ******************************************************************************/
    public static Solvency__c returnSolvencySettingsCH() {
        Solvency__c solvency = new Solvency__c(
            Name = 'Switzerland',
            Rating_1_Minimum__c = 91,
            Rating_2_Minimum__c = 81, 
            Rating_3_Minimum__c = 71,
            Rating_4_Minimum__c = 60,
            Rating_5_Minimum__c = 39,
            Rating_6_Minimum__c = 0,
            Rating_1_Maximum__c = 100,
            Rating_2_Maximum__c = 90,
            Rating_3_Maximum__c = 80,
            Rating_4_Maximum__c = 70,
            Rating_5_Maximum__c = 59,
            Rating_6_Maximum__c = 38);
        return solvency;
    }

    /*******************************************************************************
    *  Name            : returnSolvencySettingsDE()
    *  Summary         : Return settings with mapping between solvency and rating
    *  CreatedDate     : 14/06/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Solvency__c
    ******************************************************************************/
    public static Solvency__c returnSolvencySettingsDE() {
        Solvency__c solvency = new Solvency__c(
            Name = 'Germany',
            Rating_1_Minimum__c = 100,
            Rating_2_Minimum__c = 217, 
            Rating_3_Minimum__c = 246,
            Rating_4_Minimum__c = 284,
            Rating_5_Minimum__c = 303,
            Rating_6_Minimum__c = 359,
            Rating_1_Maximum__c = 216,
            Rating_2_Maximum__c = 246,
            Rating_3_Maximum__c = 283,
            Rating_4_Maximum__c = 302,
            Rating_5_Maximum__c = 358,
            Rating_6_Maximum__c = 600);
        return solvency;
    }


    /*******************************************************************************
    *  Name            : returnSolvencySettingsAT()
    *  Summary         : Return settings with mapping between solvency and rating
    *  CreatedDate     : 14/06/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Solvency__c
    ******************************************************************************/
    public static Solvency__c returnSolvencySettingsAT() {
        Solvency__c solvency = new Solvency__c(
            Name = 'Austria',
            Rating_1_Minimum__c = 100,
            Rating_2_Minimum__c = 217, 
            Rating_3_Minimum__c = 246,
            Rating_4_Minimum__c = 284,
            Rating_5_Minimum__c = 303,
            Rating_6_Minimum__c = 359,
            Rating_1_Maximum__c = 216,
            Rating_2_Maximum__c = 246,
            Rating_3_Maximum__c = 283,
            Rating_4_Maximum__c = 302,
            Rating_5_Maximum__c = 358,
            Rating_6_Maximum__c = 600);
        return solvency;
    }


    /*******************************************************************************
    *  Name            : returnSolvencySettingsLU()
    *  Summary         : Return settings with mapping between solvency and rating
    *  CreatedDate     : 14/06/2019
    *  ModifiedDate    : -
    *  Parameters      : -
    *  Returns         : Solvency__c
    ******************************************************************************/
    public static Solvency__c returnSolvencySettingsLU() {
        Solvency__c solvency = new Solvency__c(
            Name = 'Luxembourg',
            Rating_1_Minimum__c = 100,
            Rating_2_Minimum__c = 217, 
            Rating_3_Minimum__c = 246,
            Rating_4_Minimum__c = 284,
            Rating_5_Minimum__c = 303,
            Rating_6_Minimum__c = 359,
            Rating_1_Maximum__c = 216,
            Rating_2_Maximum__c = 246,
            Rating_3_Maximum__c = 283,
            Rating_4_Maximum__c = 302,
            Rating_5_Maximum__c = 358,
            Rating_6_Maximum__c = 600);
        return solvency;
    }
}