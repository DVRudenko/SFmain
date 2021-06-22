public with sharing class LocatorStation {
    public String name;         // Account Name
    public String address;      // BillingStreet & ShippingStreet
    public String city;         // BillingCity & ShippingCity
    public String postCode;     // BillingPostalCode & ShippingPostalCode
    public String telephone;    // Phone
    public String esi;          // OBN
    public String country {     // BillingCountry & ShippingCountry
        get {return country;}
        set { 
            if(value == 'Belgium'){
                value = 'Belgium-FR';
            }else if(value == 'Switzerland'){
                value = 'Switzerland-DE';
            }
            country = value; 
        }
    }

    public static List<LocatorStation> parse(String jsonStations) {
        return (List<LocatorStation>)JSON.deserialize(jsonStations, List<LocatorStation>.class);
    }
}