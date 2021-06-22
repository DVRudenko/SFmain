@isTest
private class EcoFeeConfirmationControllerTest {
    public Static Account newAccount;
    public Static Opportunity newOpportunity;
    public Static EmailTemplate teamplate;
    public Static BackOffice_Notifications__c backOfficeDE;

    @isTest
    public static void ecoFeeConfirmTest() {
        User usr = [SELECT Id FROM User WHERE Profile.Name IN ('API Only', 'System Administrator') AND isActive = true LIMIT 1];
        System.RunAs(usr) {
            createAccount();
            createOpportunity();
            createEmailTemplate();
            createCustomSetting();
            EcoFeeConfirmationController controller = new EcoFeeConfirmationController();
            ApexPages.currentPage().getParameters().put('id', newOpportunity.Id);
            controller.init();
            controller.confirmEcoFee();
            controller.rejectEcoFee();

            Opportunity updatedOpportunity = [SELECT Eco_Fee__c FROM Opportunity WHERE Id = :newOpportunity.Id LIMIT 1];
            System.assertEquals(updatedOpportunity.Eco_Fee__c, false);
        }

    }

    private static void createAccount() {
        newAccount = new Account(
                Name = 'test',
                GFN_Nr__c = '123',
                Type = 'Customer',
                Bundesland__c = 'Germany',
                BillingCountry = 'Germany',
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
                Kraftstoffverbrauch_Liter_Monat__c = 2);
        insert newAccount;
    }

    private static void createOpportunity() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Euroshell' AND sObjectType = 'Opportunity' LIMIT 1];
        newOpportunity = new Opportunity(
                Name = 'Opportunity Name',
                AccountId = newAccount.Id,
                RecordTypeId = rt.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                Eco_Fee__c = true,
                Angebotsdauer__c = '3 Monate',
                Name_of_the_payer_Account_holder__c = 'test name holder',
                IBAN__c = 'DE30160400000577000300',
                SWIFT_BIC__c = '7654321'
        );
        insert newOpportunity;
    }

    private static void createEmailTemplate() {
        teamplate = new EmailTemplate(
                Name = 'Eco Fee canceled notify to BackOffice',
                DeveloperName = 'Eco_Fee_canceled_notify_to_BackOffice',
                Subject = 'Eco Fee canceled',
                Body = 'test',
                HtmlValue = '<p>test</p>',
                TemplateType = 'Text',
                FolderId = UserInfo.getUserId()
        );
        insert teamplate;
    }

    public static void createCustomSetting() {
        backOfficeDE = new BackOffice_Notifications__c(
                Name = 'Germany',
                Email__c = 'test@test.com',
                Active__c = true
        );
        insert backOfficeDE;
    }
}