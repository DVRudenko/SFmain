public class GenerateAllStarPDFControlller {
    public Opportunity formOpportunity {get; set;}
    public Account formAccount {get; set;}
    public List<Contact> formContactList {get; set;}
    public List<Account> formSubAccountsList {get; set;}
    public Integer sizeContactList {get; set;}  
    public Integer sizeSubAccountsList {get; set;}
    public String typeOfOrganization {get; set;}
    public String industry {get; set;}


    public Map<String, String> translateIndustriesMap;
    public Map<String, String> translateTypesOfOrganizationMap;
    public Map<String, String> translateTitleMap {get; set;}

    public void init() {
        String oppId = ApexPages.currentPage().getParameters().get('id');
        if (oppId != null) {
            this.formOpportunity = [
                SELECT Name, AccountId, Umsatz__c,
                  Anzahl_der_Karten__c, Requested_monthly_Company_Credit_Spend__c, CreatedDate,
                        Data_Protection_Act_1998__c, Bevollmaechtigung__c, AGB_Datenschutzhinweise_Richtigkeit__c, Email_Marketing__c
                FROM Opportunity
                WHERE Id = :oppId
                LIMIT 1];

            this.formAccount = [
                SELECT Name, Trading_Name__c, NIP__c, REGON__c, KRS__c, Gesellschaftsform__c, Phone,
                       Mobile_Phone__c, Website, BillingStreet, BillingCity, BillingPostalCode, Country_Text__c, Allstar_Email__c,
                       ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountry, Beschaeftigte__c, Branche_NACE__c, ParentId, Sub_Account_Number__c      
                FROM Account
                WHERE Id = :formOpportunity.AccountId
                LIMIT 1];

            this.formContactList = [
                SELECT Id, AccountId, FirstName, MiddleName, LastName, Mother_s_maiden_name__c, Email, AllStar_authorised_signatory__c, AllStar_account_administrator__c,
                       AllStar_UBO__c, Salutation, Position_Funktion__c, Birthdate, PESEL_Nr__c, Phone, MailingCity, MailingStreet, MailingPostalCode, MailingCountry,
                       Country_Text__c
                FROM Contact
                WHERE AccountId = :formAccount.Id
                LIMIT 50000];

            this.sizeContactList = this.formContactList.size();

            this.formSubAccountsList = [
                SELECT Id, Name, Trading_Name__c, NIP__c, REGON__c, KRS__c, Gesellschaftsform__c, Phone,
                       Mobile_Phone__c, Website, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, Country_Text__c, Allstar_Email__c, ParentId,
                       ShippingStreet, ShippingCity, ShippingPostalCode, Beschaeftigte__c, Branche_NACE__c, Sub_Account_Number__c
                FROM Account
                WHERE ParentId = :formAccount.Id
                LIMIT 50000];

            this.sizeSubAccountsList = this.formSubAccountsList.size();

            translateTypesOfOrganizationMap = new Map<String, String>{
                'Please select' => 'Proszę wpisać',
                'The Polish Limited Liability Company (sp.z o.o)' => 'Spółka Partnerska',
                'Limited Joint Stock Partnership (S.K.A.)' => 'Spółka komandytowo-akcyjna',
                'Limited Partnership (sp. k.)' => 'Spółka komandytowa',
                'General or Registered Partnership (sp. j.)' => 'Spółka jawna',
                'Civil Law Partnership' => 'Spółka cywilna',
                'The Polish Joint Stock Company (S.A.)' => 'Spółka akcyjna',
                'Branch of an Overseas Business' => 'Oddział Przedsiębiorcy Zagranicznego',
                'Agency of an Overseas Business' => 'Agencja Przedsiębiorcy Zagranicznego',
                'Other' => 'Inne',
                'Foundation' => 'Fundacja',
                'Association' => 'Stowarzyszenie',
                'Cooperative' => 'Spółdzielnia'
            };

            if(translateTypesOfOrganizationMap.get(formAccount.Gesellschaftsform__c) != null) {
                typeOfOrganization = translateTypesOfOrganizationMap.get(formAccount.Gesellschaftsform__c);
            } else {
                typeOfOrganization = '';
            }

            translateIndustriesMap = new Map<String, String>{
                'Please select' => 'Proszę wybrać',
                'Agriculture, forestry and fishing' => 'Rolnictwo, leśnictwo, łowiectwo i rybactwo',
                'Mining and quarrying' => 'Górnictwo i wydobywanie',
                'Manufacturing' => 'Przetwórstwo przemysłowe',
                'Electricity, gas, steam and air conditioning supply' => 'Wytwarzanie i zaopatrywanie w energię elektryczną, gaz, parę wodną, gorącą wodę i powietrze do układów klimatyzacyjnych',
                'Water supply; sewerage; waste management and remediation activities' => 'Dostawa wody; gospodarowanie ściekami i odpadami oraz działalność związana z rekultywacją',
                'Construction' => 'Budownictwo',
                'Wholesale and retail trade; repair of motor vehicles and motorcycles' => 'Handel hurtowy i detaliczny; naprawa pojazdów samochodowych, włączając motocykle',
                'Transporting and storage' => 'Transport i gospodarka magazynowa',
                'Accommodation and food service activities' => 'Działalność związana z zakwaterowaniem i usługami gastronomicznymi',
                'Information and communication' => 'Informacja i komunikacja',
                'Financial and insurance activities' => 'Działalność finansowa i ubezpieczeniowa',
                'Real estate activities' => 'Działalność związana z obsługą rynku nieruchomości',
                'Professional, scientific and technical activities' => 'Działalność profesjonalna, naukowa i techniczna',
                'Administrative and support service activities' => 'Działalność w zakresie usług administrowania i działalność wspierająca',
                'Public administration and defense; compulsory social security' => 'Administracja publiczna i obrona narodowa; obowiązkowe zabezpieczenia społeczne',
                'Education' => 'Edukacja',
                'Human health and social work activities' => 'Opieka zdrowotna i pomoc społeczna',
                'Arts, entertainment and recreation' => 'Działalność związana z kulturą, rozrywką i rekreacją',
                'Activities of households as employers' => 'Gospodarstwa domowe zatrudniające pracowników; gospodarstwa domowe produkujące wyroby i świadczące usługi na własne potrzeby',
                'Activities of extraterritorial organizations and bodies' => 'Organizacje i zespoły eksterytorialne',
                'Other services activities' => 'Pozostała działalność usługowa'
            };

            if(translateIndustriesMap.get(formAccount.Branche_NACE__c) != null) {
                industry = translateIndustriesMap.get(formAccount.Branche_NACE__c);
            } else {
                industry = '';
            }

            translateTitleMap = new Map<String, String>{
                'Herr' => 'Pan',
                'Frau' => 'Pani'
            };
        }
    }  
}