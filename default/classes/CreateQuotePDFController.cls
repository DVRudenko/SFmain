public class CreateQuotePDFController {
    public Quote qoute {get; set;}
    public List<QuoteLineItem> qouteLineItems {get; set;}
    public List<Map<String, Object>> feeItems {get; set;}

    public CreateQuotePDFController() {
        String qouteId = ApexPages.CurrentPage().getparameters().get('id');
        if (qouteId != null) {
            this.qoute = [
                    SELECT  OpportunityId, Email, Phone, Contact.Name, Account.Name, BillingStreet, BillingCity,
                            BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountry,
                            TotalPrice, Vat__c, Grand_Total__c
                    FROM    Quote
                    WHERE   Id = :qouteId LIMIT 1
            ];
            this.qouteLineItems = [
                    SELECT  Product2.Id, Product2.Name, Product2.Family, 
                            Quantity, UnitPrice, TotalPrice, Discount 
                    FROM    QuoteLineItem 
                    WHERE   QuoteId = :qoute.Id
            ];
            
            Decimal quontity = 0;

            Set<Id> productsId = new Set<Id>();
            for (QuoteLineItem item : this.qouteLineItems) {
                if(item.Product2.Family == 'Carnet'){
                    productsId.add(item.Product2.Id);
                    quontity += item.Quantity;
                }
            }

            List<Offer_Fee__c> fees = [
                    SELECT  Value__c, Fee__r.Fee_Type__c
                    FROM    Offer_Fee__c 
                    WHERE   FLEETCOR_Offer__c IN :productsId AND 
                            (Fee__r.Fee_Type__c = 'for 12 month, NO CONTRACT' OR Fee__r.Fee_Type__c = 'with 12 month contract')
            ];

            this.feeItems = new List<Map<String,Object>>();
            for (Offer_Fee__c fee : fees) {
                feeItems.add(new Map<String,Object>{
                    'name'          => fee.Fee__r.Fee_Type__c,
                    'quontity'      => quontity.setScale(2),
                    'amountByOne'   => Decimal.valueOf(fee.Value__c).setScale(2),
                    'amount'        => (Decimal.valueOf(fee.Value__c) * quontity).setScale(2),
                    'amountWithVat' => (Decimal.valueOf(fee.Value__c) * quontity * (1 + this.qoute.Vat__c / 100)).setScale(2) 
                });
            }
        }
    }
}