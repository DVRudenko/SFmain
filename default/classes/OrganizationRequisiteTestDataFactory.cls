@IsTest
public with sharing class OrganizationRequisiteTestDataFactory {

    public static Account createAccount(String INN, String accName, Integer KPP) {
        Account account = new Account(
                Name = accName,
                INN__c = INN,
                KPP__c = KPP,
                Black_list_check_code__c = '0',
                Bank__c = 'АО "ТИНЬКОФФ БАНК"',
                Checking_Account__c = '88794484848484848484',
                Cor_bank_account__c = '00288679',
                Code_Word__c = 'КОДВОРД',
                BillingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                ShippingCountry = GlobalUtils.FleetcorCountries.Russia.name(),
                OGRN_ppr__c = '1035901764910',
                OKPO_ppr__c = '14673197',
                OKVED__c = 'Деятельность стоянок для транспортных средств',
                RecordTypeId = GlobalUtils.getRecordTypeId('Account', 'Russian')
        );
        return account;
    }

    public static Contact createContact(Account account) {
        Contact contact = new Contact(
                AccountId = account.Id,
                FirstName = 'Contact Test',
                LastName = 'LastName',
                Title = 'генеральный директор',
                Phone = '+73444444444',
                Email = 'test@mai.ru',
                RecordTypeId = GlobalUtils.getRecordTypeId('Contact', 'Russian')
        );
        return contact;
    }

    public static Opportunity createOpportunity(Account account) {
        Opportunity opportunity = new Opportunity(
                Name = 'test opportunity',
                StageName = GlobalUtils.getOpportunityStageName(GlobalUtils.OpportunityStage.Qualified_Lead),
                AccountId = account.Id,
                CloseDate = Date.today(),
                Projected_Liters_weekly__c = 200,
                Number_of_Vehicles__c = 100,
                Number_of_trucks__c = 1,
                Source_PP__c = 'EP',
                Source_of_Lead_o__c = 'Прочая БД',
                Product_PPR__c = 'ГАЗПРОМ – сеть АЗС',
                Number_of_Cards__c = 1,
                Virtual_cards__c = true,
                Number_Business_CARD__c = 1,
                Promo_campaign__c = '5Г01',
                Promo_Code1__c = 'реанимация',
                Paid_personal_manager__c = false,
                CategoryContract__c = 'МО',
                Our_organization__c = 'GPC',
                Amount_payment__c = 33,
                Standard_contract__c = true,
                Subject_contract__c = '22',
                Note_contract__c = '42',
                Contract_amount__c = 421,
                Express_delivery_documents__c = true,
                RecordTypeId = GlobalUtils.getRecordTypeId('Opportunity', 'Russian_Sales')

        );
        return opportunity;
    }

    public static OpportunityContactRole createOpportunityContactRole(Contact contact, Opportunity opportunity) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
                ContactId = contact.Id,
                OpportunityId = opportunity.Id,
                IsPrimary = true
        );
        return opportunityContactRole;
    }
}