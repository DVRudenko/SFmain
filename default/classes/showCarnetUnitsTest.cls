@isTest
public class showCarnetUnitsTest {
 public Id OpportunityId {get;set;}
 
 //public List< Carnet_Unit__c > getCarnet{get;set;}
    
 @isTest static void testing() {
    
    Carnet_Unit__c CU = new Carnet_Unit__c();
    Additional_Hardware__c AHW = new Additional_Hardware__c();

        Account a = new Account(
                Name = 'test',
                BillingCountry = 'Germany',
                BillingCity = 'BERG',
                BillingStreet = 'LUDWIGSTRASSE 69');
        insert a;

        Opportunity o = new Opportunity(
                Name = 'test',
                Product__c = 'Home Station offer (v.1)',
                AccountId = a.id,
                CloseDate = Date.today(),
                StageName = 'Prospecting',
                Pricing_Approval_Status__c = 'Approval Required');
        insert o;
        
        Pricebook2 pcb = new Pricebook2(
                Name = 'test',
                IsActive = true);
        insert pcb;
        
        Account_Price_Book__c apb = new Account_Price_Book__c(
                Name = 'test',
                Account__c = a.id,
                Price_Book__c = pcb.id);
        insert apb;

        CU.Opportunity__c = o.Id;
        CU.Account_Price_Book__c = apb.Id;
        CU.Price_Book__c = pcb.Id;
        CU.Contract_term__c = '24 months';
        CU.Monitoring_in_EU__c = False;
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
        insert CU;
        
        AHW.Opportunity__c = o.Id;
        AHW.Account_Price_Book__c = apb.Id;
        AHW.Price_Book__c = pcb.Id;
        AHW.Pricing_Approval_Status__c = 'Approval Required';
        AHW.Acoustic_signaling_with_LED_Amount__c = 1;
        insert AHW;
    
    test.startTest();
        Apexpages.currentPage().getParameters().put('id',o.Id);
        showCarnetUnits scu = new showCarnetUnits();
        
        scu.OpportunityId = o.Id;
        
        System.assertNotEquals(null, scu.OpportunityId);
        System.assertNotEquals(null, scu.getCarnet());
        System.assertNotEquals(null, scu.getAHW());
      	System.assertNotEquals(null, scu.getCarnetBO());
        System.assertNotEquals(null, scu.getAhwBO());
}
}