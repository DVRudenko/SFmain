@IsTest
private class FieldSalesTerritoryWrapperTest {

    @IsTest
    private static void testIndustrySort(){
        Schema.DisplayType fieldType = Schema.SObjectType.Lead.fields.getMap().get('Industry').getDescribe().getType();

        List<FieldSalesTerritoryWrapper> wrapperList = new List<FieldSalesTerritoryWrapper>();

        Lead lead1 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'В',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead1;
        FieldSalesTerritoryWrapper leadWrapper1 = new FieldSalesTerritoryWrapper(lead1,'','Industry',fieldType, 'ASC');
        wrapperList.add(leadWrapper1);

        Lead lead2 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'Б',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead2;
        FieldSalesTerritoryWrapper leadWrapper2 = new FieldSalesTerritoryWrapper(lead2,'','Industry', fieldType, 'ASC');
        wrapperList.add(leadWrapper2);

        Lead lead3 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'А',
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead3;
        FieldSalesTerritoryWrapper leadWrapper3 = new FieldSalesTerritoryWrapper(lead3,'','Industry', fieldType, 'ASC');
        wrapperList.add(leadWrapper3);

        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 1000000, Industry = 'Г',
                Phone = '+71234567891', BillingStreet = 'САНКТ-ПЕТЕРБУРГ', INN__C = '1234567899999', BillingCountry = 'Russia');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50),  AccountId = account.id);
        insert opportunity;
        opportunity = [SELECT id, Account.Industry From Opportunity where id =:opportunity.Id];
        FieldSalesTerritoryWrapper oppWrapper = new FieldSalesTerritoryWrapper(opportunity,'','NumberOfEmployees', fieldType, 'ASC');
        wrapperList.add(oppWrapper);

        wrapperList.sort();

        System.assertEquals('А', wrapperList[0].sObj.get('Industry'));
        System.assertEquals('Б', wrapperList[1].sObj.get('Industry'));
        System.assertEquals('В', wrapperList[2].sObj.get('Industry'));
        System.assertEquals('Г', wrapperList[3].sObj.getSObject('Account').get('Industry'));
    }

    @IsTest
    private static void testNumberOfEmployeesSort(){
        Schema.DisplayType fieldType = Schema.SObjectType.Account.fields.getMap().get('NumberOfEmployees').getDescribe().getType();

        List<FieldSalesTerritoryWrapper> wrapperList = new List<FieldSalesTerritoryWrapper>();

        Lead lead1 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'В', NumberOfEmployees = 1,
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead1;
        FieldSalesTerritoryWrapper leadWrapper1 = new FieldSalesTerritoryWrapper(lead1,'','NumberOfEmployees',fieldType, 'DESC');
        wrapperList.add(leadWrapper1);

        Lead lead2 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'А',  NumberOfEmployees = 3,
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead2;
        FieldSalesTerritoryWrapper leadWrapper2 = new FieldSalesTerritoryWrapper(lead2,'','NumberOfEmployees', fieldType, 'DESC');
        wrapperList.add(leadWrapper2);

        Lead lead3 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'Б',  NumberOfEmployees = 2,
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead3;
        FieldSalesTerritoryWrapper leadWrapper3 = new FieldSalesTerritoryWrapper(lead3,'','NumberOfEmployees', fieldType, 'DESC');
        wrapperList.add(leadWrapper3);

        Account account = new Account(Name = 'test12345678910987654321', BillingPostalCode = '123', Rating_FS__c = 1000000,  NumberOfEmployees = 15,
                Phone = '+71234567891', BillingStreet = 'САНКТ-ПЕТЕРБУРГ', INN__C = '1234567899999', BillingCountry = 'Russia');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'test12345678910987654321', StageName = 'Отказ', Probability = 0, CloseDate = date.today(),
                Last_Owner_Change_Date_RUS__c = system.now().addDays(-50), AccountId = account.id);
        insert opportunity;
        opportunity = [SELECT id, Account.NumberOfEmployees From Opportunity where id =:opportunity.Id];
        FieldSalesTerritoryWrapper oppWrapper = new FieldSalesTerritoryWrapper(opportunity,'','NumberOfEmployees', fieldType, 'DESC');
        wrapperList.add(oppWrapper);

        wrapperList.sort();

        System.assertEquals(15, wrapperList[0].sObj.getSObject('Account').get('NumberOfEmployees'));
        System.assertEquals(3, wrapperList[1].sObj.get('NumberOfEmployees'));
        System.assertEquals(2, wrapperList[2].sObj.get('NumberOfEmployees'));
        System.assertEquals(1, wrapperList[3].sObj.get('NumberOfEmployees'));
    }

    @IsTest
    private static void testRatingFSSort(){
        Schema.DisplayType fieldType = Schema.SObjectType.Account.fields.getMap().get('Rating_FS__c').getDescribe().getType();

        List<FieldSalesTerritoryWrapper> wrapperList = new List<FieldSalesTerritoryWrapper>();

        Lead lead1 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'В', NumberOfEmployees = 1,
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', Rating_FS__c = 1.25,
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead1;
        FieldSalesTerritoryWrapper leadWrapper1 = new FieldSalesTerritoryWrapper(lead1,'','Rating_FS__c',fieldType, 'DESC');
        wrapperList.add(leadWrapper1);

        Lead lead2 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'А',  NumberOfEmployees = 3,
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia',Rating_FS__c = 4.5,
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead2;
        FieldSalesTerritoryWrapper leadWrapper2 = new FieldSalesTerritoryWrapper(lead2,'','Rating_FS__c', fieldType, 'DESC');
        wrapperList.add(leadWrapper2);

        Lead lead3 = new Lead(Phone = '+71098765432', LastName = 'pro567verkaAAAAAAA567', Company = 'pro567verkaAAAAAAA567',
                Email = 'mail123456@gmail.com', Salutation = 'Herr', INN__C = '1234567888888', Industry = 'Б',  NumberOfEmployees = 2,
                Date_of_First_Contact_Inbound_Outbound__c = date.today(), Country = 'Russia', Rating_FS__c = 1.75,
                First_Contact_Inbound_Outbound__c = 'Inbound Call', Source_of_lead__c = 'Сайт Petrolplus.ru');
        insert lead3;
        FieldSalesTerritoryWrapper leadWrapper3 = new FieldSalesTerritoryWrapper(lead3,'','Rating_FS__c', fieldType, 'DESC');
        wrapperList.add(leadWrapper3);

        wrapperList.sort();
        system.debug(wrapperList);

        System.assertEquals(4.5, wrapperList[0].sObj.get('Rating_FS__c'));
        System.assertEquals(1.75, wrapperList[1].sObj.get('Rating_FS__c'));
        System.assertEquals(1.25, wrapperList[2].sObj.get('Rating_FS__c'));
    }
}