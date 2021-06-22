public with sharing class OrganizationRequisiteDataManager {
    public static List<Opportunity> findOpportunityById(Id oppId) {
        return [
                SELECT
                Id,
                AccountId,
                Projected_Liters_weekly__c,
                Number_of_cars__c,
                Number_of_trucks__c,
                Source_PP__c,
                Source_of_Lead_o__c,
                Product_PPR__c,
                Number_of_Cards__c,
                Virtual_cards__c,
                Number_Business_CARD__c,
                Promo_campaign__c,
                Promo_Code1__c,
                Paid_personal_manager__c,
                CategoryContract__c,
                ALL_Cards__c,
                PPR_Electronic_document_management__c,
                Amount_payment__c,
                Our_organization__c,
                Subject_contract__c,
                Note_contract__c,
                Standard_contract__c,
                Contract_amount__c,
                Express_delivery_documents__c,
                Personal_office_phone__c
                FROM Opportunity
                WHERE Id =:oppId
        ];
    }

    public static List<Account> findAccountById(Id accId) {
        return  [
                SELECT
                Id,
                Name,
                INN__c,
                KPP__c,
                OGRN_ppr__c,
                OKVED__c,
                OKPO_ppr__c,
                BillingAddress,
                ShippingAddress,
                BillingCity,
                BillingPostalCode,
                BillingStreet,
                ShippingCity,
                ShippingPostalCode,
                ShippingStreet,
                CustomBillingState__c,
                CustomBillingArea__c,
                CustomShippingState__c,
                Black_list_check_decision__c,
                Bank__c,
                Checking_Account__c,
                Cor_bank_account__c,
                Code_Word__c,
                SWIFT_BIC__c,
                Adress_delivery__c,
                Original_document_courier_info__c,
                Cards_delivery_courier_info__c
                FROM Account
                WHERE Id =:accId
        ];
    }

    public static List<OpportunityContactRole> findOpportunityContactRolesByOpportunityId(Id oppId) {
        return  [
                SELECT
                Id,
                Contact.Id,
                Contact.Title,
                Contact.FirstName,
                Contact.MiddleName,
                Contact.LastName,
                Contact.Name,
                Contact.Email,
                Contact.Phone,
                Contact.Additional_Emails__c,
                Contact.Additional_Phones__c,
                IsPrimary
                FROM OpportunityContactRole
                WHERE Opportunity.Id =:oppId
        ];
    }

    public static List<Credit_Factory_Report__c> findCreditFactoryReportsByOppId(Id oppId) {
        return [
                SELECT
                Id,
                Name,
                Credit_Limit__c,
                RU_Client_Choice__c,
                RU_Scoring_Payment_Time_Limit__c,
                RU_Scoring_Credit_Period__c,
                RecordTypeId,
                RU_scoring_decision__c,
                RU_Scoring_expiration_date__c,
                RU_scoring_type__c,
                RU_scoring_decision_status__c
                FROM Credit_Factory_Report__c
                WHERE Opportunity__c = :oppId
                AND RU_scoring_type__c = :CFUtils.ScoringType.Prescoring.name()
        ];
    }
}