@isTest
public class NewCarnetOBDctrlTest {
    public Opportunity opportunity {get; set;}
    public String opportunityId;
    public String carnetunitId;
    static Boolean isntValid;
    public Boolean hide {get;set;}
        
    @isTest static void testing() {
    
    Carnet_Unit__c CU = new Carnet_Unit__c();
    Carnet_Unit__c CU2 = new Carnet_Unit__c();

        Account a = new Account(
                Name = 'test',
                BillingCountry = 'Poland',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69');
        insert a;
        
                Pricebook2 pcb = new Pricebook2(
                Name = 'test',
                IsActive = true,
                Standard_Unit_Package__c = 289);
        insert pcb;
        
                Account_Price_Book__c apb = new Account_Price_Book__c(
                Name = 'test',
                Account__c = a.id,
                Price_Book__c = pcb.id);
        insert apb;
        
        Opportunity o = new Opportunity(
                Name = 'test',
                Product__c = 'Home Station offer (v.1)',
                AccountId = a.id,
                CloseDate = Date.today(),
                StageName = 'Prospecting',
                Account_Price_Book__c = apb.id,
                Pricing_Approval_Status__c = 'Pending Approval');
        insert o;

        CU.Opportunity__c = o.Id;
        CU.Account_Price_Book__c = apb.Id;
        CU.Price_Book__c = pcb.Id;
        CU.Contract_term__c = '24 months';
        CU.Pricing_Approval_Status__c = 'Approval Required';
        CU.Archiving_Price__c = 100;
        CU.Tariff_World_Price__c = 100;
        CU.Driving_Style_Price__c = 100;
        CU.Reservations_Price__c = 100;
        CU.On_line_position_above_standard_Price__c = 100;
        CU.Web_services_Price__c = 100;
        CU.Service_Alarm_Price__c = 100;
        CU.Standard_Unit_Package__c = 100;
        CU.Unit_Activation__c = 100;
        CU.Installation__c = 100;
        CU.Number_of_Units__c = 1;
        CU.Monitoring_in_other_European_countries__c = false;
        CU.Archiving__c = false;
        CU.Driving_Style__c = false;
        CU.Reservations__c = false;
        CU.On_line_position_above_standard__c = false;
        CU.Web_services__c = false;
        CU.Service_Alarm__c = false;
        CU.Driving_Style_Price__c = 1;
        CU.Reservations_Price__c = 1;
        CU.Archiving_Price__c = 1;
        CU.On_line_position_above_standard_Price__c = 1;
        CU.Web_services_Price__c = 1;
        CU.Service_Alarm_Price__c = 1;
        CU.Tariff_World_Price__c = 17;
        CU.Unit_Activation__c = 0;
        CU.Installation__c = 0;
        CU.Standard_Unit_Package__c = 289;
        CU.CurrencyIsoCode = 'PLN';
        CU.Standard_Unit_Package3__c = 289;
        CU.Standard_Unit_Package_6_15_c__c = 269;
        CU.Standard_Unit_Package_16_c__c = 259;
        CU.Carnet_Tariff__c = 'Standard 24';
        insert CU;
        
        test.startTest();

        Apexpages.currentPage().getParameters().put('id',o.Id);

        NewCarnetOBDctrl newCU = new NewCarnetOBDctrl();
        newCU.OpportunityId = o.Id;
        System.assertEquals(o.Id, newCU.OpportunityId);
        newCU.init();

        System.assertNotEquals(newCU.opportunity, o);
        System.assertEquals(newCU.CU.Account_Price_Book__c, o.Account_Price_Book__c);


        Opportunity op = new Opportunity(
                Name = 'test',
                Product__c = 'Home Station offer (v.1)',
                AccountId = a.id,
                CloseDate = Date.today(),
                StageName = 'Prospecting',
                Account_Price_Book__c = apb.id,
                Pricing_Approval_Status__c = 'Not Required');
        insert op;
        Apexpages.currentPage().getParameters().put('id',op.Id);


        newCU.OpportunityId = op.Id;
        System.assertEquals(op.Id, newCU.OpportunityId);
        newCU.init();

        System.assertNotEquals(newCU.opportunity, o);
        System.assertEquals(newCU.CU.Account_Price_Book__c, op.Account_Price_Book__c);


        newCU.save();
        
        test.stopTest();
        /*
        NewCarnetOBDctrl newCU = new NewCarnetOBDctrl();


        newCu.save();
        
        newCU.OpportunityId = o.Id;
        
        NewCarnetOBDctrl newCU2 = new NewCarnetOBDctrl();
       
        PageReference pg = new PageReference('/'+ newCU.OpportunityId);
        
        System.assertNotEquals(null, newCU.OpportunityId);
        System.assertEquals(null, newCU.init());
        System.assertNotEquals(null, CU.Account_Price_Book__c);
        System.assertNotEquals(null, newCU.save());
        System.assertEquals(null, newCU2.save());
        System.assertNotEquals(null, newCU.cancel());


        */

        }
    }