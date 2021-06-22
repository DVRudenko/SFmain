public with sharing class CreateCommercialCarnetPDFController {
    public Account account {get; set;}
    public Opportunity opportunity {get; set;}

    public String oppId{get; set;}
    public Opportunity opp{get; set;}
    public Decimal TotalOneTimePaymentVAT{get; set;}
    public Decimal TotalMonthlyPaymentVAT{get; set;}
    public Decimal OneTimePaymentGoods{get; set;}
    public Decimal OneTimePaymentServices{get; set;}
    public Account acc{get; set;}
    public Contact con{get; set;}

    public List<Carnet_Order_Items__c> items {get;set;}
    public List<Carnet_Order_Items__c> monthlyItems {get;set;}
    public List<Carnet_Order_Items__c> oneTimeItems {get;set;}
    public List<Carnet_Order_Items__c> goods {get;set;}
    public List<Carnet_Order_Items__c> services {get;set;}
    //Do tohoto listu půjdou pouze Názvy a Ceny
    public List<Carnet_Order_Items__c> infoItems {get;set;}

    // Required extension constructor (empty, no-op)
    public CreateCommercialCarnetPDFController(ApexPages.StandardController controller) {
        items = new List<Carnet_Order_Items__c>();
        infoItems = new List<Carnet_Order_Items__c>();
        oppId = ApexPages.CurrentPage().getparameters().get('id');
        String carnetOBDRecId = GlobalUtils.returnRecordTypeId('Carnet_Unit__c', 'Carnet OBD');

        acc = new Account();
        con = new Contact();
        opp = new Opportunity();

        acc.Id = [SELECT AccountId FROM Opportunity WHERE Id = :oppId][0].AccountId;

        List<OpportunityContactRole> clist = [SELECT ContactID FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityID = :oppId];
        if(clist.size() > 0){
            con.Id = clist[0].ContactId;
        }


        acc = [SELECT Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Steuernummer__c FROM Account WHERE Id = :acc.Id LIMIT 1][0];
        con = [SELECT Name, Email, Phone FROM Contact WHERE Id = :con.Id LIMIT 1][0];

        opp = [SELECT Name, OwnerId, Total_One_time_Payment__c, Form_of_Payment__c, Monthly_Payment_Method__c, Total_Monthly_Payment__c, Total_Monthly_Payment_Fee__c, Total_Monthly_Payment_Formula__c, Number_of_GPS_units__c, Sales_Basic_Monthly_Fee_Discount__c, Account_Price_Book__r.Price_Book__r.VAT__c, Account_Price_Book__r.Price_Book__r.Standard_Unit_Package__c, Product__c, One_time_Payment_Goods__c, One_time_Payment_Services__c FROM Opportunity WHERE Id = :oppId LIMIT 1][0];

        TotalOneTimePaymentVAT = opp.Total_One_time_Payment__c * (1 + (opp.Account_Price_Book__r.Price_Book__r.VAT__c/100));
        TotalMonthlyPaymentVAT = opp.Total_Monthly_Payment_Formula__c * (1 + (opp.Account_Price_Book__r.Price_Book__r.VAT__c/100));
        OneTimePaymentGoods = opp.One_time_Payment_Goods__c * (1 + (opp.Account_Price_Book__r.Price_Book__r.VAT__c/100));
        OneTimePaymentServices = opp.One_time_Payment_Services__c * (1 + (opp.Account_Price_Book__r.Price_Book__r.VAT__c/100));


        this.opportunity = new Opportunity();
        this.opportunity.Id = oppId;

        try{
            List<Carnet_Unit__c> listOfUnits = [SELECT Id, Name, CurrencyIsoCode, Carnet_Tariff__c, Number_of_Units__c, Standard_Unit_Package__c, Unit_Activation__c, Installation__c, Carnet_Tariff_Price__c, Carnet_Tariff_Price_DISCOUNT__c, Contract_length__c, Monitoring_in_other_European_countries__c, Tariff_World_Price__c, Driving_Style__c, Driving_Style_Price__c, Reservations__c, Reservations_Price__c, Archiving__c, Archiving_Price__c, On_line_position_above_standard__c, On_line_position_above_standard_Price__c, Web_services__c, Web_services_Price__c, Service_Alarm__c, Service_Alarm_Price__c, Discount_Amount__c, Total_Discount_Amount__c, Monitoring_in_EU__c, Monitoring_in_EU_Price__c, Prepaid__c, RecordTypeId FROM Carnet_Unit__c WHERE Opportunity__c = :oppId AND Pricing_Approval_Status__c != 'Declined'];

            for(Carnet_Unit__c unit : listOfUnits){
                Carnet_Order_Items__c item = new Carnet_Order_Items__c();
                Carnet_Order_Items__c it = new Carnet_Order_Items__c();

                //Pokud je už něco v listu, musíme projet záznamy a případně upravit množství, ...



                //Pokud v listu ještě není carnet tariff

                item = new Carnet_Order_Items__c();
                item.Name = unit.Carnet_Tariff__c;
                item.Price__c = unit.Carnet_Tariff_Price_DISCOUNT__c;
                

                //pokud tam je item se stejným názvem i cenou
                if(infoItems.contains(item)){
                    for (Carnet_Order_Items__c edit : items){
                        if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                            System.debug('asdasd');
                            edit.Amount__c += unit.Number_of_Units__c;
                            edit.Total_Discount_Amount__c += unit.Total_Discount_Amount__c;
                        }
                    }
                }else{
                    it = new Carnet_Order_Items__c();
                    it.Name = unit.Carnet_Tariff__c;
                    it.Price__c = unit.Carnet_Tariff_Price_DISCOUNT__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    //item.Price__c = unit.Carnet_Tariff_Price__c;
                    //item.Price__c = unit.Carnet_Tariff_Price_DISCOUNT__c;
                    infoItems.add(it);

                    item = new Carnet_Order_Items__c();
                    item.Name = unit.Carnet_Tariff__c;
                    item.Price__c = unit.Carnet_Tariff_Price_DISCOUNT__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    
                    //item.Price__c = unit.Carnet_Tariff_Price__c;
                    //item.Price__c = unit.Carnet_Tariff_Price_DISCOUNT__c;
                    item.CurrencyIsoCode = unit.CurrencyIsoCode;
                    item.Opportunity__c = oppId;
                    item.Amount__c = unit.Number_of_Units__c;
                    item.Sales_Basic_Monthly_Fee_Discount__c = opp.Sales_Basic_Monthly_Fee_Discount__c;
                    item.Discount_Amount__c = unit.Discount_Amount__c;
                    item.Total_Discount_Amount__c = unit.Total_Discount_Amount__c;
                    item.Total_Discount_Amount_VAT__c = unit.Total_Discount_Amount__c * (1 + (opp.Account_Price_Book__r.Price_Book__r.VAT__c/100));
                    //Polský název
                    item.PLName__c = unit.Carnet_Tariff__c;
                    if(unit.RecordTypeId == carnetOBDRecId && unit.Prepaid__c){
                        item.Amount__c = unit.Number_of_Units__c;
                        item.Sales_Basic_Monthly_Fee_Discount__c = opp.Sales_Basic_Monthly_Fee_Discount__c;
                        item.Discount_Amount__c = unit.Discount_Amount__c;
                        item.Total_Discount_Amount__c = unit.Total_Discount_Amount__c;
                        item.Total_Discount_Amount_VAT__c = unit.Total_Discount_Amount__c * (1 + (opp.Account_Price_Book__r.Price_Book__r.VAT__c/100));
                        item.Monthly__c = false;
                        item.isService__c = true;
                        item.isTariff__c = true;
                    }
                    else {
                        item.Monthly__c = true;
                    }
                    item.isTariff__c = true;
                    items.add(item);
                }



                //Definice nového Standard Unit Package
                item = new Carnet_Order_Items__c();
                item.Name = 'Standard Unit Package';
                item.Price__c = unit.Standard_Unit_Package__c;
                item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                //pokud tam je item se stejným názvem i cenou
                if(infoItems.contains(item)){
                    for (Carnet_Order_Items__c edit : items){
                        if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                            edit.Amount__c += unit.Number_of_Units__c;
                        }
                    }
                }else{
                    it = new Carnet_Order_Items__c();
                    it.Name = 'Standard Unit Package';
                    it.Price__c = unit.Standard_Unit_Package__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    infoItems.add(it);
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Standard Unit Package';
                    item.Price__c = unit.Standard_Unit_Package__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    item.CurrencyIsoCode = unit.CurrencyIsoCode;
                    item.Opportunity__c = oppId;
                    item.Amount__c = unit.Number_of_Units__c;
                    //Polský název
                    if(unit.RecordTypeId == carnetOBDRecId){
                        item.PLName__c = 'Carnet Pakiet OBD';
                    }
                    else {
                        item.PLName__c = 'Carnet Pakiet standardowy';
                    }
                    item.Monthly__c = false;
                    item.isGoods__c = true;
                    items.add(item);
                }

                //Definice nového Unit_Activation__c
                item = new Carnet_Order_Items__c();
                item.Name = 'Unit Activation';
                item.Price__c = unit.Unit_Activation__c;
                item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                //pokud tam je item se stejným názvem i cenou
                if(infoItems.contains(item)){
                    for (Carnet_Order_Items__c edit : items){
                        if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                            edit.Amount__c += unit.Number_of_Units__c;
                        }
                    }
                }else{
                    it = new Carnet_Order_Items__c();
                    it.Name = 'Unit Activation';
                    it.Price__c = unit.Unit_Activation__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    infoItems.add(it);
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Unit Activation';
                    item.Price__c = unit.Unit_Activation__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    item.CurrencyIsoCode = unit.CurrencyIsoCode;
                    item.Opportunity__c = oppId;
                    item.Amount__c = unit.Number_of_Units__c;
                    //Polský název
                    item.PLName__c = 'Aktywacja pojazdu';
                    item.Monthly__c = false;
                    item.isService__c = true;
                    items.add(item);
                }

                //Definice nového Installation
                item = new Carnet_Order_Items__c();
                item.Name = 'Installation';
                item.Price__c = unit.Installation__c;
                item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                //pokud tam je item se stejným názvem i cenou
                if(infoItems.contains(item)){
                    for (Carnet_Order_Items__c edit : items){
                        if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                            edit.Amount__c += unit.Number_of_Units__c;
                        }
                    }
                }else{
                    it = new Carnet_Order_Items__c();
                    it.Name = 'Installation';
                    it.Price__c = unit.Installation__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    infoItems.add(it);
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Installation';
                    item.Price__c = unit.Installation__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    item.CurrencyIsoCode = unit.CurrencyIsoCode;
                    item.Opportunity__c = oppId;
                    item.Amount__c = unit.Number_of_Units__c;
                    //Polský název
                    if(unit.RecordTypeId == carnetOBDRecId){
                        item.PLName__c = 'Instalacja jednostki - samodzielna instalacja';
                    }
                    else {
                        item.PLName__c = 'Instalacja jednostki';
                    }
                    item.Monthly__c = false;
                    item.isService__c = true;
                    items.add(item);
                }

                //Pokud je Tariff Europe
                if(unit.Monitoring_in_other_European_countries__c){
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Tariff Europe';
                    item.Price__c = unit.Tariff_World_Price__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                    //pokud tam je item se stejným názvem i cenou
                    if(infoItems.contains(item)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                                edit.Amount__c += unit.Number_of_Units__c;
                            }
                        }
                    }else{
                        it = new Carnet_Order_Items__c();
                        it.Name = 'Tariff Europe';
                        it.Price__c = unit.Tariff_World_Price__c;
                        it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Tariff Europe';
                        item.Price__c = unit.Tariff_World_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Number_of_Units__c;
                        //Polský název
                        item.PLName__c = 'Taryfa Europa';
                        if(unit.RecordTypeId == carnetOBDRecId && unit.Prepaid__c){
                            item.Monthly__c = false;
                            item.isService__c = true;
                            item.isEU__c = true;
                            item.Contract_length__c = unit.Contract_length__c;
                        }
                        else {
                            item.Monthly__c = true;
                        }
                        items.add(item);
                    }
                }

                //Pokud je Monitoring_in_EU__c
                if(unit.Monitoring_in_EU__c){
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Tariff EU';
                    item.Price__c = unit.Monitoring_in_EU_Price__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                    //pokud tam je item se stejným názvem i cenou
                    if(infoItems.contains(item)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                                edit.Amount__c += unit.Number_of_Units__c;
                            }
                        }
                    }else{
                        it = new Carnet_Order_Items__c();
                        it.Name = 'Tariff EU';
                        it.Price__c = unit.Monitoring_in_EU_Price__c;
                        it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Tariff EU';
                        item.Price__c = unit.Monitoring_in_EU_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Number_of_Units__c;
                        //Polský název
                        item.PLName__c = 'Taryfa Unia Europejska';
                        item.isService__c = true;
                        item.Monthly__c = false;
                        item.isEU__c = true;
                        item.Contract_length__c = unit.Contract_length__c;
                        items.add(item);
                    }
                }

                //Pokud je Driving_Style__c
                if(unit.Driving_Style__c){
                    system.debug('DRIVING STYLE');
                    system.debug(unit.Id);
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Driving Style';
                    item.Price__c = unit.Driving_Style_Price__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                    //pokud tam je item se stejným názvem i cenou
                    if(infoItems.contains(item)){
                        system.debug(infoItems.contains(item));
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                                edit.Amount__c += unit.Number_of_Units__c;
                            }
                        }
                    }else{
                        it = new Carnet_Order_Items__c();
                        it.Name = 'Driving Style';
                        it.Price__c = unit.Driving_Style_Price__c;
                        it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Driving Style';
                        item.Price__c = unit.Driving_Style_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Number_of_Units__c;
                        //Polský název
                        item.PLName__c = 'Style jazdy';
                        if(unit.RecordTypeId == carnetOBDRecId && unit.Prepaid__c){
                            item.Monthly__c = false;
                            item.isService__c = true;
                        }
                        else {
                            item.Monthly__c = true;
                        }
                        items.add(item);
                    }
                }

                //Pokud je Reservations__c
                if(unit.Reservations__c){
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Reservations';
                    item.Price__c = unit.Reservations_Price__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                    //pokud tam je item se stejným názvem i cenou
                    if(infoItems.contains(item)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                                edit.Amount__c += unit.Number_of_Units__c;
                            }
                        }
                    }else{
                        it = new Carnet_Order_Items__c();
                        it.Name = 'Reservations';
                        it.Price__c = unit.Reservations_Price__c;
                        it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reservations';
                        item.Price__c = unit.Reservations_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Number_of_Units__c;
                        //Polský název
                        item.PLName__c = 'Rezerwacja';
                        if(unit.RecordTypeId == carnetOBDRecId && unit.Prepaid__c){
                            item.Monthly__c = false;
                            item.isService__c = true;
                        }
                        else {
                            item.Monthly__c = true;
                        }
                        items.add(item);
                    }
                }

                //Archivace
                if(unit.Archiving__c){
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Archiving';
                    item.Price__c = unit.Archiving_Price__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                    //pokud tam je item se stejným názvem i cenou
                    if(infoItems.contains(item)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                                edit.Amount__c += unit.Number_of_Units__c;
                            }
                        }
                    }else{
                        it = new Carnet_Order_Items__c();
                        it.Name = 'Archiving';
                        it.Price__c = unit.Archiving_Price__c;
                        it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Archiving';
                        item.Price__c = unit.Archiving_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Number_of_Units__c;
                        //Polský název
                        item.PLName__c = 'Archiwizacja';
                        if(unit.RecordTypeId == carnetOBDRecId && unit.Prepaid__c){
                            item.Monthly__c = false;
                            item.isService__c = true;
                            item.isEU__c = true;
                            item.Contract_length__c = unit.Contract_length__c;
                        }
                        else {
                            item.Monthly__c = true;
                        }
                        items.add(item);
                    }
                }

                //On-line position above standard
                if(unit.On_line_position_above_standard__c){
                    item = new Carnet_Order_Items__c();
                    item.Name = 'On-line position above standard';
                    item.Price__c = unit.On_line_position_above_standard_Price__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                    //pokud tam je item se stejným názvem i cenou
                    if(infoItems.contains(item)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                                edit.Amount__c += unit.Number_of_Units__c;
                            }
                        }
                    }else{
                        it = new Carnet_Order_Items__c();
                        it.Name = 'On-line position above standard';
                        it.Price__c = unit.On_line_position_above_standard_Price__c;
                        it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'On-line position above standard';
                        item.Price__c = unit.On_line_position_above_standard_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Number_of_Units__c;
                        //Polský název
                        item.PLName__c = 'On-line pozycje powyżej standardu';
                        if(unit.RecordTypeId == carnetOBDRecId && unit.Prepaid__c){
                            item.Monthly__c = false;
                            item.isService__c = true;
                        }
                        else {
                            item.Monthly__c = true;
                        }
                        items.add(item);
                    }
                }

                //Web services
                if(unit.Web_services__c){
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Web services';
                    item.Price__c = unit.Web_services_Price__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                    //pokud tam je item se stejným názvem i cenou
                    if(infoItems.contains(item)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                                edit.Amount__c += unit.Number_of_Units__c;
                            }
                        }
                    }else{
                        it = new Carnet_Order_Items__c();
                        it.Name = 'Web services';
                        it.Price__c = unit.Web_services_Price__c;
                        it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Web services';
                        item.Price__c = unit.Web_services_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Number_of_Units__c;
                        //Polský název
                        item.PLName__c = 'Usługi sieci web';
                        if(unit.RecordTypeId == carnetOBDRecId && unit.Prepaid__c){
                            item.Monthly__c = false;
                            item.isService__c = true;
                            item.isEU__c = true;
                            item.Contract_length__c = unit.Contract_length__c;
                        }
                        else {
                            item.Monthly__c = true;
                        }
                        items.add(item);
                    }
                }

                //Service_Alarm__c
                if(unit.Service_Alarm__c){
                    item = new Carnet_Order_Items__c();
                    item.Name = 'Service Alarm';
                    item.Price__c = unit.Service_Alarm_Price__c;
                    item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;

                    //pokud tam je item se stejným názvem i cenou
                    if(infoItems.contains(item)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == item.Name && edit.Price__c == item.Price__c){
                                edit.Amount__c += unit.Number_of_Units__c;
                            }
                        }
                    }else{
                        it = new Carnet_Order_Items__c();
                        it.Name = 'Service Alarm';
                        it.Price__c = unit.Service_Alarm_Price__c;
                        it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Service Alarm';
                        item.Price__c = unit.Service_Alarm_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Number_of_Units__c;
                        //Polský název
                        item.PLName__c = 'Usługa Alarm';
                        if(unit.RecordTypeId == carnetOBDRecId && unit.Prepaid__c){
                            item.Monthly__c = false;
                            item.isService__c = true;
                        }
                        else {
                            item.Monthly__c = true;
                        }
                        items.add(item);
                    }
                }


            }



        } catch(Exception ex){
            System.debug('Zero units');
        }


        try{
            List<Additional_Hardware__c> listOfHw = [SELECT Id, CurrencyIsoCode, Guarding_the_vehicle_one_switch_Amount__c, Guarding_the_vehicle_one_switch_Price__c, Guarding_the_vehicle_reader_Amount__c, Guarding_the_vehicle_reader_Price__c, Button_Panic_Price__c, Button_Panic2_Price__c, Button_Panic_Amount__c, Button_Panic2_Amount__c, Guarding_cargo_space_Price__c, Guarding_cargo_space_Amount__c, Reader_Dalas_Price__c, Reader_Dalas_Amount__c, Reader_RFID_Slim_Price__c, Reader_RFID_Slim_Amount__c, Reader_Inditag_Price__c, Reader_Inditag_Amount__c, Reader_Mifare_Price__c, Reader_Mifare_Amount__c, Reader_HIDProx_Price__c, Reader_HIDProx_Amount__c, Reader_Multi_125_Price__c, Reader_Multi_125_Amount__c, Reader_Multi_ISO_Price__c, Reader_Multi_ISO_Amount__c, Reader_Legic_Price__c, Reader_Legic_Amount__c, Dalas_chip_Price__c, Dalas_chip_Amount__c, RFID_fobs_Price__c, RFID_fobs_Amount__c, RFID_adhesive_chip_Price__c, RFID_adhesive_chip_Amount__c, Piezoelectric_siren_Price__c, Piezoelectric_siren_Amount__c, Temperature_measurementCargoSpace_Price__c, Temperature_measurementCargoSpace_Amount__c, Calibrating_transducer_PT100_Price__c, Calibrating_transducer_PT100_Amount__c, Temperature_sensor_Pt100B_Price__c, Temperature_sensor_Pt100B_Amount__c, Temperature_sensor_Pt100A_Price__c, Temperature_sensor_Pt100A_Amount__c, Temperature_sensor_Dalas_Price__c, Temperature_sensor_Dalas_Amount__c, X1_m_cable_to_the_temperature_Price__c, X1_m_cable_to_the_temperature_Amount__c, X1_m_silicone_cable_temp_sensor_Price__c, X1_m_silicone_cable_temp_sensor_Amount__c, Plastic_temperature_sensor_holder_Price__c, Plastic_temperature_sensor_holder_Amount__c, Basic_switch_Price__c, Basic_switch_Amount__c, Adhesive_switch_P_S_Price__c, Adhesive_switch_P_S_Amount__c, Adhesive_switch_P_S_with_diode_LED_Price__c, Adhesive_switch_P_S_withDiode_LED_Amoun__c, Cable_CAN_Price__c, Cable_CAN_Amount__c, CAN_GO_CLICK_Price__c, CAN_GO_CLICK_Amount__c, Power_supply_power_cable_harnesses_Price__c, Power_supplyPower_cable_harnesses_Amount__c, Antenna_GPS_FLAT_Price__c, Antenna_GPS_FLAT_Amount__c, Antenna_GPS_Shark_Price__c, Antenna_GPS_Shark_Amount__c, Spare_battery_for_CN85_1_4_Price__c, Spare_battery_for_CN85_1_4_Amount__c, Can_Bus_transducer_MCB_02_Price__c, Can_Bus_transducer_MCB_02_Amount__c, Microwave_sensor_Price__c, Microwave_sensor_Amount__c, Acoustic_signaling_with_LED_Price__c, Acoustic_signaling_with_LED_Amount__c, Siren_Alarm_Price__c, Siren_Alarm_Amount__c FROM Additional_Hardware__c WHERE Opportunity__c = :oppId AND Pricing_Approval_Status__c != 'Declined'];

            for(Additional_Hardware__c unit : listOfHw) {
                Carnet_Order_Items__c item = new Carnet_Order_Items__c();
                Carnet_Order_Items__c it = new Carnet_Order_Items__c();

                if(unit.Guarding_the_vehicle_one_switch_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Guarding_the_vehicle_one_switch_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Hidden switch';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Guarding_the_vehicle_one_switch_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Hidden switch';
                        item.Price__c = unit.Guarding_the_vehicle_one_switch_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Guarding_the_vehicle_one_switch_Amount__c;
                        //Polský název
                        item.PLName__c = 'Pilnowanie uruchomienia pojazdu za pomocą skrytego przełącznika';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Guarding_the_vehicle_reader_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Guarding_the_vehicle_reader_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Guarding the vehicle being set in motion, using a reader';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Guarding_the_vehicle_reader_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Guarding the vehicle being set in motion, using a reader';
                        item.Price__c = unit.Guarding_the_vehicle_reader_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Guarding_the_vehicle_reader_Amount__c;
                        //Polský název
                        item.PLName__c = 'Pilnowanie uruchomienia pojazdu za pomocą czytnika';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Button_Panic_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Button_Panic_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Button Panic';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Button_Panic_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Button Panic';
                        item.Price__c = unit.Button_Panic_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Button_Panic_Amount__c;
                        //Polský název
                        item.PLName__c = 'Przycisk Panic';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Button_Panic2_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Button_Panic2_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Button Panic';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Button_Panic2_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Button Panic';
                        item.Price__c = unit.Button_Panic2_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Button_Panic2_Amount__c;
                        //Polský název
                        item.PLName__c = 'Przycisk Panic';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Guarding_cargo_space_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Guarding_cargo_space_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Guarding cargo space';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Guarding_cargo_space_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Guarding cargo space';
                        item.Price__c = unit.Guarding_cargo_space_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Guarding_cargo_space_Amount__c;
                        //Polský název
                        item.PLName__c = 'Pilnowanie pomieszczenia ładunkowego';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Reader_Dalas_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Reader_Dalas_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Reader Dalas';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Reader_Dalas_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reader Dalas';
                        item.Price__c = unit.Reader_Dalas_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Reader_Dalas_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czytnik Dalas';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Reader_RFID_Slim_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Reader_RFID_Slim_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Reader RFID Slim';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Reader_RFID_Slim_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reader RFID Slim';
                        item.Price__c = unit.Reader_RFID_Slim_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Reader_RFID_Slim_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czytnik RFID Slim';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Reader_Inditag_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Reader_Inditag_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Reader Inditag';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Reader_Inditag_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reader Inditag';
                        item.Price__c = unit.Reader_Inditag_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Reader_Inditag_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czytnik Inditag';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Reader_Mifare_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Reader_Mifare_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Reader Mifare';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Reader_Mifare_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reader Mifare';
                        item.Price__c = unit.Reader_Mifare_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Reader_Mifare_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czytnik Mifare';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Reader_HIDProx_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Reader_HIDProx_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Reader HIDProx';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Reader_HIDProx_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reader HIDProx';
                        item.Price__c = unit.Reader_HIDProx_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Reader_HIDProx_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czytnik HIDProx';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Reader_Multi_125_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Reader_Multi_125_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Reader Multi 125';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Reader_Multi_125_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reader Multi 125';
                        item.Price__c = unit.Reader_Multi_125_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Reader_Multi_125_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czytnik Multi125';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Reader_Multi_ISO_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Reader_Multi_ISO_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Reader Multi ISO';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Reader_Multi_ISO_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reader Multi ISO';
                        item.Price__c = unit.Reader_Multi_ISO_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Reader_Multi_ISO_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czytnik Multi ISO';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Reader_Legic_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Reader_Legic_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Reader Legic';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Reader_Legic_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Reader Legic';
                        item.Price__c = unit.Reader_Legic_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Reader_Legic_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czytnik Legic';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Dalas_chip_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Dalas_chip_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Dalas chip';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Dalas_chip_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Dalas chip';
                        item.Price__c = unit.Dalas_chip_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Dalas_chip_Amount__c;
                        //Polský název
                        item.PLName__c = 'Dalas chip';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.RFID_fobs_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.RFID_fobs_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'RFID fobs';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.RFID_fobs_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'RFID fobs';
                        item.Price__c = unit.RFID_fobs_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.RFID_fobs_Amount__c;
                        //Polský název
                        item.PLName__c = 'RFID brelok';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.RFID_adhesive_chip_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.RFID_adhesive_chip_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'RFID adhesive chip';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.RFID_adhesive_chip_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'RFID adhesive chip';
                        item.Price__c = unit.RFID_adhesive_chip_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.RFID_adhesive_chip_Amount__c;
                        //Polský název
                        item.PLName__c = 'RFID przylepny chip';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Piezoelectric_siren_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Piezoelectric_siren_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Piezoelectric siren';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Piezoelectric_siren_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Piezoelectric siren';
                        item.Price__c = unit.Piezoelectric_siren_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Piezoelectric_siren_Amount__c;
                        //Polský název
                        item.PLName__c = 'Piezoelektryczna syrena';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Temperature_measurementCargoSpace_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Temperature_measurementCargoSpace_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Temperature measurement in the cargo space';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Temperature_measurementCargoSpace_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Temperature measurement in the cargo space';
                        item.Price__c = unit.Temperature_measurementCargoSpace_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Temperature_measurementCargoSpace_Amount__c;
                        //Polský název
                        item.PLName__c = 'Pomiar temperatury w pomieszczeniu ładunkowym';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Calibrating_transducer_PT100_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Calibrating_transducer_PT100_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Calibrating transducer PT100';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Calibrating_transducer_PT100_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Calibrating transducer PT100';
                        item.Price__c = unit.Calibrating_transducer_PT100_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Calibrating_transducer_PT100_Amount__c;
                        //Polský název
                        item.PLName__c = 'Kalibrowalny przetwornik PT100';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Temperature_sensor_Pt100B_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Temperature_sensor_Pt100B_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Temperature sensor Pt100B with cable 1m';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Temperature_sensor_Pt100B_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Temperature sensor Pt100B with cable 1m';
                        item.Price__c = unit.Temperature_sensor_Pt100B_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Temperature_sensor_Pt100B_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czujnik temperatury Pt100B z kablem 1m';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Temperature_sensor_Pt100A_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Temperature_sensor_Pt100A_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Temperature sensor Pt100A with cable 1m';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Temperature_sensor_Pt100A_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Temperature sensor Pt100A with cable 1m';
                        item.Price__c = unit.Temperature_sensor_Pt100A_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Temperature_sensor_Pt100A_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czujnik temperatury Pt100A z kablem 1m';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Temperature_sensor_Dalas_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Temperature_sensor_Dalas_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Temperature sensor Dalas';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Temperature_sensor_Dalas_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Temperature sensor Dalas';
                        item.Price__c = unit.Temperature_sensor_Dalas_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Temperature_sensor_Dalas_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czujnik temperatury Dalas';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.X1_m_cable_to_the_temperature_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.X1_m_cable_to_the_temperature_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = '1 m cable to the temperature sensor';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.X1_m_cable_to_the_temperature_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = '1 m cable to the temperature sensor';
                        item.Price__c = unit.X1_m_cable_to_the_temperature_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.X1_m_cable_to_the_temperature_Amount__c;
                        //Polský název
                        item.PLName__c = '1m kabla do czujnika temperatury';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.X1_m_silicone_cable_temp_sensor_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.X1_m_silicone_cable_temp_sensor_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = '1 m silicone cable to the temperature sensor';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.X1_m_silicone_cable_temp_sensor_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = '1 m silicone cable to the temperature sensor';
                        item.Price__c = unit.X1_m_silicone_cable_temp_sensor_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.X1_m_silicone_cable_temp_sensor_Amount__c;
                        //Polský název
                        item.PLName__c = '1m kabla silikonowego do czujnika temperatury';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Plastic_temperature_sensor_holder_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Plastic_temperature_sensor_holder_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Plastic temperature sensor holder';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Plastic_temperature_sensor_holder_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Plastic temperature sensor holder';
                        item.Price__c = unit.Plastic_temperature_sensor_holder_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Plastic_temperature_sensor_holder_Amount__c;
                        //Polský název
                        item.PLName__c = 'Plastikowy uchwyt czujnika temperatury';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Basic_switch_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Basic_switch_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Basic switch';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Basic_switch_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Basic switch';
                        item.Price__c = unit.Basic_switch_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Basic_switch_Amount__c;
                        //Polský název
                        item.PLName__c = 'Podstawowy przełącznik P/S';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Adhesive_switch_P_S_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Adhesive_switch_P_S_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Adhesive switch P/S';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Adhesive_switch_P_S_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Adhesive switch P/S';
                        item.Price__c = unit.Adhesive_switch_P_S_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Adhesive_switch_P_S_Amount__c;
                        //Polský název
                        item.PLName__c = 'Przełącznik przylepny P/S';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Adhesive_switch_P_S_withDiode_LED_Amoun__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Adhesive_switch_P_S_with_diode_LED_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Adhesive switch P/S with a diode LED';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Adhesive_switch_P_S_withDiode_LED_Amoun__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Adhesive switch P/S with a diode LED';
                        item.Price__c = unit.Adhesive_switch_P_S_with_diode_LED_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Adhesive_switch_P_S_withDiode_LED_Amoun__c;
                        //Polský název
                        item.PLName__c = 'Przełącznik przylepny P/S z diodą LED';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Cable_CAN_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Cable_CAN_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Cable CAN';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Cable_CAN_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Cable CAN';
                        item.Price__c = unit.Cable_CAN_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Cable_CAN_Amount__c;
                        //Polský název
                        item.PLName__c = 'CAN kabel';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.CAN_GO_CLICK_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.CAN_GO_CLICK_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'CAN GO CLICK';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.CAN_GO_CLICK_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'CAN GO CLICK';
                        item.Price__c = unit.CAN_GO_CLICK_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.CAN_GO_CLICK_Amount__c;
                        //Polský název
                        item.PLName__c = 'CAN GO CLICK';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Power_supplyPower_cable_harnesses_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Power_supply_power_cable_harnesses_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Power supply power cable harnesses';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Power_supplyPower_cable_harnesses_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Power supply power cable harnesses';
                        item.Price__c = unit.Power_supply_power_cable_harnesses_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Power_supplyPower_cable_harnesses_Amount__c;
                        //Polský název
                        item.PLName__c = 'Zasilająca wiązka kabli';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Antenna_GPS_FLAT_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Antenna_GPS_FLAT_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Antenna GPS FLAT';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Antenna_GPS_FLAT_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Antenna GPS FLAT';
                        item.Price__c = unit.Antenna_GPS_FLAT_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Antenna_GPS_FLAT_Amount__c;
                        //Polský název
                        item.PLName__c = 'Antena GPS FLAT';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Antenna_GPS_Shark_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Antenna_GPS_Shark_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Antenna GPS SHARK';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Antenna_GPS_Shark_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Antenna GPS SHARK';
                        item.Price__c = unit.Antenna_GPS_Shark_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Antenna_GPS_Shark_Amount__c;
                        //Polský název
                        item.PLName__c = 'Antena GPS SHARK';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Spare_battery_for_CN85_1_4_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Spare_battery_for_CN85_1_4_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Spare battery for CN85 1.4';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Spare_battery_for_CN85_1_4_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Spare battery for CN85 1.4';
                        item.Price__c = unit.Spare_battery_for_CN85_1_4_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Spare_battery_for_CN85_1_4_Amount__c;
                        //Polský název
                        item.PLName__c = 'Bateria zapasowa do CN85 1.4';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Can_Bus_transducer_MCB_02_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Can_Bus_transducer_MCB_02_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Can Bus transducer MCB-02';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Can_Bus_transducer_MCB_02_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Can Bus transducer MCB-02';
                        item.Price__c = unit.Can_Bus_transducer_MCB_02_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Can_Bus_transducer_MCB_02_Amount__c;
                        //Polský název
                        item.PLName__c = 'Can Bus przetwornik MCB-02';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Microwave_sensor_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Microwave_sensor_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Microwave sensor';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Microwave_sensor_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Microwave sensor';
                        item.Price__c = unit.Microwave_sensor_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Microwave_sensor_Amount__c;
                        //Polský název
                        item.PLName__c = 'Czujnik mikrofalowy';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Acoustic_signaling_with_LED_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Acoustic_signaling_with_LED_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Acoustic signaling with LED';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Acoustic_signaling_with_LED_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Acoustic signaling with LED';
                        item.Price__c = unit.Acoustic_signaling_with_LED_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Acoustic_signaling_with_LED_Amount__c;
                        //Polský název
                        item.PLName__c = 'Sygnalizacja akustyczna z LED';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }

                if(unit.Siren_Alarm_Amount__c > 0){
                    it = new Carnet_Order_Items__c();
                    it.Price__c = unit.Siren_Alarm_Price__c;
                    it.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                    it.Name = 'Siren Alarm';
                    if(infoItems.contains(it)){
                        for (Carnet_Order_Items__c edit : items){
                            if(edit.Name == it.Name && edit.Price__c == it.Price__c){
                                edit.Amount__c += unit.Siren_Alarm_Amount__c;
                            }
                        }
                    }else{
                        infoItems.add(it);
                        item = new Carnet_Order_Items__c();
                        item.Name = 'Siren Alarm';
                        item.Price__c = unit.Siren_Alarm_Price__c;
                        item.VAT__c = opp.Account_Price_Book__r.Price_Book__r.VAT__c;
                        item.CurrencyIsoCode = unit.CurrencyIsoCode;
                        item.Opportunity__c = oppId;
                        item.Amount__c = unit.Siren_Alarm_Amount__c;
                        //Polský název
                        item.PLName__c = 'Syrena Alarm';
                        item.Monthly__c = false;
                        item.isGoods__c = true;
                        items.add(item);
                    }
                }


            }

        }catch(Exception ex){
            System.debug('Zero HW');
        }



        monthlyItems = new List<Carnet_Order_Items__c>();
        oneTimeItems = new List<Carnet_Order_Items__c>();
        goods = new List<Carnet_Order_Items__c>();
        services = new List<Carnet_Order_Items__c>();
        for (Carnet_Order_Items__c orderItem : items){
            if(orderItem.monthly__c == true){
                if(orderItem.Price__c > 0){
                    if(orderItem.isTariff__c){
                        orderItem.Total_Amount__c = ((orderItem.Price__c) * orderItem.Amount__c)-orderItem.Total_Discount_Amount__c;
                        orderItem.Price__c = orderItem.Price__c - orderItem.Discount_Amount__c;
                        orderItem.Total_Amount_VAT__c = ((orderItem.Price__c * orderItem.Amount__c)-orderItem.Total_Discount_Amount__c) * (1 + (orderItem.VAT__c/100));
                    }else{
                        orderItem.Total_Amount__c = orderItem.Price__c * orderItem.Amount__c;
                        orderItem.Total_Amount_VAT__c = (orderItem.Price__c * orderItem.Amount__c) * (1 + (orderItem.VAT__c/100));
                    }


                }else{
                    orderItem.Total_Amount__c = orderItem.Price__c;
                    orderItem.Total_Amount_VAT__c = (orderItem.Price__c) * (1 + (orderItem.VAT__c/100));
                }

                monthlyItems.add(orderItem);
            }
            else{
                if(orderItem.Price__c > 0){
                    if(orderItem.isTariff__c){
                        orderItem.Total_Amount__c = ((orderItem.Price__c) * orderItem.Amount__c)-orderItem.Total_Discount_Amount__c;
                        orderItem.Price__c = orderItem.Price__c - orderItem.Discount_Amount__c;
                        orderItem.Total_Amount_VAT__c = ((orderItem.Price__c * orderItem.Amount__c)-orderItem.Total_Discount_Amount__c) * (1 + (orderItem.VAT__c/100));
                    }
                    if(orderItem.isEU__c){
                        orderItem.Total_Amount__c = orderItem.Price__c * orderItem.Contract_length__c * orderItem.Amount__c;
                        orderItem.Total_Amount_VAT__c = (orderItem.Price__c * orderItem.Contract_length__c * orderItem.Amount__c) * (1 + (orderItem.VAT__c/100));
                    }
                    else{
                        orderItem.Total_Amount__c = orderItem.Price__c * orderItem.Amount__c;
                        orderItem.Total_Amount_VAT__c = (orderItem.Price__c * orderItem.Amount__c) * (1 + (orderItem.VAT__c/100));
                    }

                }else{
                    orderItem.Total_Amount__c = orderItem.Price__c;
                    orderItem.Total_Amount_VAT__c = (orderItem.Price__c) * (1 + (orderItem.VAT__c/100));
                }
                if(orderItem.isGoods__c){
                    goods.add(orderItem);
                }
                else if(orderItem.isService__c){
                    services.add(orderItem);
                }
                oneTimeItems.add(orderItem);
            }
        }



        //monthlyItems.sort();
        //oneTimeItems.sort();
    }
}