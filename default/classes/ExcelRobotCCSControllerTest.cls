/**
 * Created by marekhaken on 14/01/2020.
 */

@IsTest
private class ExcelRobotCCSControllerTest {
    @IsTest
    static void testExcelRobotCCSCZ() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');
        List<User> User = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC' LIMIT 1];

        Account acc = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsAccRecId);
        insert acc;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = acc.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opp = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Order entered',
                AccountId = acc.Id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                Product_Solicited__c = 'CCS Limit',
                LeadSource = 'Web CCS');
        insert opp;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = acc.Id,
                Opportunity__c = opp.Id,
                CurrencyIsoCode = 'CZK',
                Product_Country__c = 'CZ',
                OwnerId = User.get(0).Id,
                Note_CC__c = 'TEST',
                Note_CCS__c = 'TEST',
                Order_Note__c = 'TEST',
                RecordTypeId = LimitRecId);
        insert ccsOrder;


        Test.StartTest();
        PageReference pageRef = Page.ExcelRobotCCS; // Add your VF page Name here
        pageRef.getParameters().put('Id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);

        ExcelRobotCCSController er = new ExcelRobotCCSController();
        Test.StopTest();
    }

    @IsTest
    static void testExcelRobotCCSSK() {
        String ccsOppoRecId = GlobalUtils.returnRecordTypeId('Opportunity', 'CCS Opportunity Layout');
        String ccsAccRecId = GlobalUtils.returnRecordTypeId('Account', 'CCS');
        String LimitRecId = GlobalUtils.returnRecordTypeId('CCS_Order__c', 'CCS Limit');
        List<User> User = [SELECT Id FROM User WHERE CompanyName = 'INTERCODEC' LIMIT 1];

        Account acc = new Account(
                Name = 'TESTCCS',
                BillingPostalCode = '12345',
                Phone = '+72234567891',
                BillingStreet = 'TEST',
                BillingCountry = 'Czech Republic',
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsAccRecId);
        insert acc;

        Contact contact = new Contact(
                Salutation = 'Herr',
                LastName = 'Test',
                AccountId = acc.Id,
                Email = 'test123123@test.com');
        insert contact;

        Opportunity opp = new Opportunity(
                Name = 'CCSTest',
                StageName = 'Order entered',
                AccountId = acc.Id,
                Probability = 0,
                OwnerId = User.get(0).Id,
                RecordTypeId = ccsOppoRecId,
                CloseDate = date.today(),
                Product_Solicited__c = 'CCS Limit',
                LeadSource = 'Web CCS');
        insert opp;

        CCS_Order__c ccsOrder = new CCS_Order__c(
                Name = 'CCSTest',
                Account__c = acc.Id,
                Opportunity__c = opp.Id,
                CurrencyIsoCode = 'EUR',
                Product_Country__c = 'SK',
                OwnerId = User.get(0).Id,
                Note_CC__c = 'TEST',
                Note_CCS__c = 'TEST',
                Order_Note__c = 'TEST',
                RecordTypeId = LimitRecId);
        insert ccsOrder;

        Vozidlo_CCS_Carnet__c voz = new Vozidlo_CCS_Carnet__c(
                CCS_Order__c = ccsOrder.Id,
                Name = 'Vozidlo1'
        );
        insert voz;

        CCS_Additional_HW__c addHW = new CCS_Additional_HW__c(
                CCS_Order__c = ccsOrder.Id,
                Name = 'AdditionalHW1'
        );
        insert addHW;

        Karta_CCS_Limit__c kartaLimit = new Karta_CCS_Limit__c(
                CCS_Order__c = ccsOrder.Id,
                Poznamka_k_objednavce__c = 'TEST',
                Name = 'LimitKarta'
        );
        insert kartaLimit;

        Karta_CCS_Bonus_Fleet__c kartaFleet = new Karta_CCS_Bonus_Fleet__c(
                CCS_Order__c = ccsOrder.Id,
                Name = 'FleetKarta'
        );
        insert kartaFleet;

        Karta_CCS_Bonus__c kartaBonus = new Karta_CCS_Bonus__c(
                CCS_Order__c = ccsOrder.Id,
                Name = 'BonusKarta'
        );
        insert kartaBonus;

        CCS_Contact__c orderContact = new CCS_Contact__c(
                CCS_Order__c = ccsOrder.Id,
                Email__c = 'info@intercodec.cz',
                First_Name__c = 'Jméno',
                Last_Name__c = 'Příjmení',
                //Role__c = 'Authorised signatory',
                Account_administrator__c = True,
                Authorised_signatory__c = False
        );
        insert orderContact;


        Test.StartTest();
        PageReference pageRef = Page.ExcelRobotCCS; // Add your VF page Name here
        pageRef.getParameters().put('Id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);

        ExcelRobotCCSController er = new ExcelRobotCCSController();
        Test.StopTest();
    }
}