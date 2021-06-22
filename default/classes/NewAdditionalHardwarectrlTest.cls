@isTest
public class NewAdditionalHardwarectrlTest {
    public Opportunity opportunity {get; set;}
    public String opportunityId;
    public Additional_Hardware__c AHW {get; set;}
    public String ahwId;
    public Boolean isntValid {get;set;}
    public Boolean hide {get;set;}
    
    public static testMethod void testing() {
        
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
        
        AHW.Opportunity__c = o.Id;
        AHW.Account_Price_Book__c = apb.Id;
        AHW.Price_Book__c = pcb.Id;
        AHW.Pricing_Approval_Status__c = 'Approval Required';
        AHW.Acoustic_signaling_with_LED_Amount__c = 1;
        AHW.CurrencyIsoCode = 'PLN';
        insert AHW;
        
        test.startTest();
        Apexpages.currentPage().getParameters().put('id',o.Id);
        NewAdditionalHardware newAHW = new NewAdditionalHardware();
        
        newAHW.OpportunityId = o.Id;
        
        System.assertNotEquals(null, newAHW.OpportunityId);
        System.assertEquals(null, newAHW.init());
        System.assertEquals(null, newAHW.save());
        System.assertNotEquals(null, newAHW.cancel());
       
    } 
    
  }