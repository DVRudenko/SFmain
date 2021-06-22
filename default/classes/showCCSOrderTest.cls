@isTest
public class showCCSOrderTest {
public Id OpportunityId {get;set;}
    
@isTest static void testing() {
        
        Account a = new Account(
              Name = 'VÁCLAV KALAŠ',                                         // Account Name
              CCS_Company_ID__c = '71506233',                                // CCS Company ID
              Phone = '+420321321321',                                       // Phone
              Agree_to_process_pers_data_for_marketing__c = false,           // Agree to process pers data for marketing
              Agree_to_receive_comm_info_by_email__c = false,                // Agree to receive comm info by email
              Agree_to_telephone_contact__c = true,                          // Agree to telephone contact
              AccountSource = 'OZ login - Web CCS (objednávka CCS Limit)',   // Account Source
              Customer_IP_Address__c = '82.113.58.203',                      // Customer IP Address
              Date_Agreed_GDPR__c = Date.today(),  // Date Agreed (GDPR)
              BillingCountry = 'Czech Republic',
              CCS_account_merge_status__c = false);
       insert a;
       
       Opportunity o = new Opportunity(
              Name = 'VÁCLAV KALAŠ',                                         // Opportunity Name
              Type = 'New GFN',                                              // Type
              CloseDate = Date.today(),                                      // Close Date
              AccountId = a.Id,                                              // Account Name
              StageName = 'Order entered',                                   // Stage
              Primary_Contact_Phone__c = '+420321321321',                    // Primary Contact Phone
              CCS_Cribis__c = 'F',                                           // CCS Cribis
              CCS_MerlinID__c = '00161',                                     // CCS MerlinID
              CCS_priobjednavka__c = false,                                  // Přiobjednávka?
              Agree_to_telephone_contact__c = true,                          // Agree to telephone contact
              Agree_to_receive_comm_info_by_email__c = false,                // Agree to receive comm info by email
              Agree_to_process_pers_data_for_marketing__c = false,           // Agree to process pers data for marketing
              Do_Not_Call__c = false,                                        // Do Not Call
              Agree_to_VAT_Recovery_TC__c = false,                           // Agree to VAT-Recovery T&C
              CCS_Accident_Insurance__c = true,                              // CCS Accident Insurance
              Product_Solicited__c = 'CCS Limit',                            // Product Solicited
              LeadSource = 'OZ login - Web CCS (objednávka CCS Limit)',      // Lead Source
              Sec_Channel__c = 'Inbound',                                    // Sec. Channel
              Channel__c = 'web',                                            // Channel
              Customer_IP_Address__c = '82.113.58.203',                      // Customer IP Address
              Date_Agreed_GDPR__c = Date.today());
        insert o;
        
        CCS_Order__c ccsOrder = new CCS_Order__c(
              Name = 'Václav Kalaš',                       // CCS Order
              Account__c = a.Id,                           // Account
              OZ_Number__c = 'oznum',                      // OZ Number
              Opportunity__c = o.Id,                       // Opportunity
              Offer_Type__c = 'CCS Limit Moje síť/M4',     // Offer Type
              CCS_MerlinID__c = '00161',                   // CCS Merlin ID
              Number_of_Cards__c = 2,                      // Number of Cards
              Monthly_Bill_Email__c = false,               // Monthly Bill - Email
              Number_of_Card_Variants__c = 0,              // Number of Card Variants
              Monthly_Bill_Post__c = false,                // Monthly Bill - Post
              Number_of_Vehicles__c = 0,                   // Number of Vehicles
              Accident_Insurance__c = false,               // Accident Insurance
              T_C_Agree__c = false,                        // T&C Agree
              Financial_Credit__c = 0,                     // Financial Credit
              Card_Issuance_Price__c = 0,                  // Card Issuance Price
              Monthly_Fixed_Card_Payment__c = 0,           // Monthly Fixed Card Payment
              Total_Monthly_Payment__c = 0,                // Total Monthly Payment
              Price__c = 0);
        insert ccsOrder;
        
    
    test.startTest();
        Apexpages.currentPage().getParameters().put('id',o.Id);
        showCCSOrder SCO = new showCCSOrder();
        
        SCO.OpportunityId = o.Id;
        
        System.assertNotEquals(null, SCO.OpportunityId);
        System.assertNotEquals(null, SCO.getCCSOrder());
    }
}