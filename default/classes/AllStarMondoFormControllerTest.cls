@isTest
private class AllStarMondoFormControllerTest {
    public static Account newAccount;
    public static Account newSubAccount;
    public static Opportunity newOpportunity;
    public static Contact newContact;


    /*******************************************************************************
    *  Name            : testUpdateObjects()
    *  Summary         : testing update fields  
    *  CreatedDate     : 14/04/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testUpdateObjects() {
        createParentAccount();
        createSubAccount();
        createOpportunity();
        createContact();

        Test.startTest();  
        AllStarMondoFormController controller = new AllStarMondoFormController();
        ApexPages.currentPage().getParameters().put('id', newAccount.Id);
        controller.initCheckPassword();
        controller.password = newAccount.Web_form_password__c;
        controller.login();
        controller.init();
        //update parent account
        controller.registeredName = 'accName updated';
        //update opportunity
        controller.turnover = '321';
        //update contact
        controller.repsMap.get(1).firstName = 'conName updated';
        //update sub account
        controller.subAccMap.get(1).nameSubAcc = 'subAccName updated';
        controller.goToStepOne();
        controller.goToStepTwo();
        controller.goToStepThree();
        controller.validationByStepThreeAndSave();
        controller.generatePdf();

        Account updatedAcc = [
            SELECT Name
            FROM Account
            WHERE Id = :newAccount.Id
            LIMIT 1];

        Account updatedSubAcc = [
            SELECT Name
            FROM Account
            WHERE Id = :newSubAccount.Id AND
                  ParentId = : newAccount.Id
            LIMIT 1];

        Opportunity updatedOpp = [
            SELECT Umsatz__c
            FROM Opportunity
            WHERE Id = :newOpportunity.Id
            LIMIT 1];

        Contact updatedCon = [
            SELECT FirstName
            FROM Contact
            WHERE Id = :newContact.Id
            LIMIT 1];

        System.assertEquals(updatedAcc.Name, 'ACCNAME UPDATED');
        System.assertEquals(updatedSubAcc.Name, 'SUBACCNAME UPDATED');
        System.assertEquals(updatedOpp.Umsatz__c, '321');
        System.assertEquals(updatedCon.FirstName, 'CONNAME UPDATED');
        Test.stopTest();
}

    /*******************************************************************************
    *  Name            : testInsertAndUpdateObjects()
    *  Summary         : testing insert fields  
    *  CreatedDate     : 14/04/2017
    *  Parameters      : 
    *  Returns         : void
    ******************************************************************************/
    @isTest
    public static void testInsertAndUpdateObjects() {
        createParentAccount();

        Test.startTest();  
        AllStarMondoFormController controller = new AllStarMondoFormController();
        controller.objectId = newAccount.Id;
        controller.init();
        //update parent account
        controller.registeredName = 'accName updated';
        //insert opportunity
        controller.turnover = '111';
        controller.companyCreditSpend = '333';
        controller.numberOfIndividualCards = '777';
        controller.agreementDataProtection = true;
        controller.agreementAuthorityToApply = true;
        controller.agreementTermsAndConditions = true;
        //insert contact
        controller.repsMap.get(1).selectedTitle = 'Mr.';
        controller.repsMap.get(1).position = 'CEO';
        controller.repsMap.get(1).firstName = 'conName inserted';
        controller.repsMap.get(1).middleName = 'test';
        controller.repsMap.get(1).lastName = 'test';
        controller.repsMap.get(1).motherMaidenName = 'test';
        controller.repsMap.get(1).email = 'test@test.com';
        controller.repsMap.get(1).birthday = String.valueOf(Date.today());
        controller.repsMap.get(1).authorisedSignatory = true;
        controller.repsMap.get(1).accountAdministrator = false;
        controller.repsMap.get(1).ubo = true;
        controller.repsMap.get(1).pesel = '1121321';
        controller.repsMap.get(1).telephoneNumber = '+48 7777777';
        controller.repsMap.get(1).mailingStreet = 'test street';
        controller.repsMap.get(1).mailingCity = 'test city';
        controller.repsMap.get(1).mailingPostcode = '123213';
        controller.repsMap.get(1).mailingCountry = 'Poland';
        //insert sub account    

        controller.showBlockEntityUBO = false;
        controller.subAccMap.get(1).nameSubAcc = 'subAccName insert';
        controller.subAccMap.get(1).streetSubAcc = 'subAccStreet insert';
        controller.subAccMap.get(1).countrySubAcc = 'Poland';
        controller.subAccMap.get(1).yearOfRegistrationSubAcc = '2017';

        controller.validationByStepOne();
        controller.validationByStepTwo();
        controller.validationByStepThreeAndSave();
        controller.generatePdf();

        //coverage static lists
        controller.getTypesOfOrganization();
        controller.getNumberOfEmployees();
        controller.getYearOfRegistration();
        controller.getIndustries();
        controller.getTitle();

        Account updatedAcc = [
            SELECT Name
            FROM Account
            WHERE Id = :newAccount.Id
            LIMIT 1];

        Account insertedSubAcc = [
            SELECT Name
            FROM Account
            WHERE ParentId = : newAccount.Id
            LIMIT 1];

        Opportunity insertedOpp = [
            SELECT Umsatz__c
            FROM Opportunity
            WHERE Umsatz__c = '111' AND
                  Requested_monthly_Company_Credit_Spend__c = 333 AND
                  Anzahl_der_Karten__c = 777
            LIMIT 1];

        Contact insertedCon = [
            SELECT FirstName
            FROM Contact
            WHERE AccountId = :newAccount.Id
            LIMIT 1];

        System.assertEquals(updatedAcc.Name, 'ACCNAME UPDATED');
        System.assertEquals(insertedOpp.Umsatz__c, '111');
        System.assertEquals(insertedCon.FirstName, 'CONNAME INSERTED');
        System.assertEquals(insertedSubAcc.Name, 'SUBACCNAME INSERT');
        Test.stopTest();
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
            BillingCountry = 'Poland',
            BillingStreet = 'street name',
            BillingCity = 'Warsaw',
            BillingPostalCode = '123455',
            Allstar_Email__c = 'test@test.com',
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