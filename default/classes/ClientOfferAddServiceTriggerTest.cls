@IsTest
private class ClientOfferAddServiceTriggerTest {
    @IsTest
    static void testAddAdditionalServicesToOpp() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp'
        );
        insert opp;

        List<Additional_Service__c> addservices = new List<Additional_Service__c>();
        Additional_Service__c addService = new Additional_Service__c(
                Type__c = 'Eco Fee',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'ecofeepl'
        );
        Additional_Service__c addService2 = new Additional_Service__c(
                Type__c = 'Paper Invoice',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'paperinvoicepl'
        );
        Additional_Service__c addService3 = new Additional_Service__c(
                Type__c = 'VAT Refund',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'vatrefundpl'
        );
        addservices.add(addService);
        addservices.add(addService2);
        addservices.add(addService3);
        insert addservices;

        List<Client_Offer_Additional_Service__c> oasList = new List<Client_Offer_Additional_Service__c>();
        Client_Offer_Additional_Service__c oas = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Selected__c = true,
                Additional_Service__c = addService.Id
        );
        Client_Offer_Additional_Service__c oas2 = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Selected__c = true,
                Additional_Service__c = addService2.Id
        );
        Client_Offer_Additional_Service__c oas3 = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Selected__c = true,
                Additional_Service__c = addService3.Id
        );
        oasList.add(oas);
        oasList.add(oas2);
        oasList.add(oas3);
        insert oasList;

        Opportunity testOpp = [
                SELECT Eco_Fee__c, VAT_Recovery__c, Papierrechnung__c
                FROM Opportunity
                WHERE Id = :opp.Id
        ];
        System.assert(testOpp.Eco_Fee__c == true);
        System.assert(testOpp.VAT_Recovery__c == true);
        System.assert(testOpp.Papierrechnung__c == true);

        for (Client_Offer_Additional_Service__c oasitem : oasList) {
            oasitem.Selected__c = false;
        }
        update oasList;

        Opportunity testOpp2 = [
                SELECT Eco_Fee__c, VAT_Recovery__c, Papierrechnung__c
                FROM Opportunity
                WHERE Id = :opp.Id
        ];
        System.assert(testOpp2.Eco_Fee__c == false);
        System.assert(testOpp2.VAT_Recovery__c == false);
        System.assert(testOpp2.Papierrechnung__c == false);
    }


    @IsTest
    static void testRemoveServicesFromOpp() {
        Opportunity opp = new Opportunity(
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp'
        );
        insert opp;

        List<Additional_Service__c> addservices = new List<Additional_Service__c>();
        Additional_Service__c addService = new Additional_Service__c(
                Type__c = 'Eco Fee',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'ecofeepl'
        );
        Additional_Service__c addService2 = new Additional_Service__c(
                Type__c = 'Paper Invoice',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'pipl'
        );
        Additional_Service__c addService3 = new Additional_Service__c(
                Type__c = 'VAT Refund',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'vatpl'
        );
        addservices.add(addService);
        addservices.add(addService2);
        addservices.add(addService3);
        insert addservices;

        List<Client_Offer_Additional_Service__c> oasList = new List<Client_Offer_Additional_Service__c>();
        Client_Offer_Additional_Service__c oas = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Additional_Service__c = addService.Id,
                Selected__c = true
        );
        Client_Offer_Additional_Service__c oas2 = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Additional_Service__c = addService2.Id
        );
        Client_Offer_Additional_Service__c oas3 = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Additional_Service__c = addService3.Id
        );
        oasList.add(oas);
        oasList.add(oas2);
        oasList.add(oas3);
        insert oasList;

        Test.startTest();
        delete oasList;

        Opportunity testOpp = [
                SELECT Eco_Fee__c, VAT_Recovery__c, Papierrechnung__c
                FROM Opportunity
                WHERE Id = :opp.Id
        ];
        System.assert(testOpp.Eco_Fee__c == false);
        System.assert(testOpp.VAT_Recovery__c == false);
        System.assert(testOpp.Papierrechnung__c == false);
        Test.stopTest();
    }


    @IsTest
    static void testPrefillAccountLookup () {
        Account account = new Account(
                Name = 'test',
                BillingCountry = 'Poland'
        );
        insert account;

        Opportunity opp = new Opportunity(
                AccountId = account.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Name = 'test opp'
        );
        insert opp;

        List<Additional_Service__c> addservices = new List<Additional_Service__c>();
        Additional_Service__c addService = new Additional_Service__c(
                Type__c = 'Eco Fee',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'ecofeepl'
        );
        Additional_Service__c addService2 = new Additional_Service__c(
                Type__c = 'Paper Invoice',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'pipl'
        );
        Additional_Service__c addService3 = new Additional_Service__c(
                Type__c = 'VAT Refund',
                Amount__c = 10,
                Country__c = 'Poland',
                Integration_Name__c = 'vatpl'
        );
        addservices.add(addService);
        addservices.add(addService2);
        addservices.add(addService3);
        insert addservices;

        List<Client_Offer_Additional_Service__c> oasList = new List<Client_Offer_Additional_Service__c>();
        Client_Offer_Additional_Service__c oas = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Additional_Service__c = addService.Id,
                Selected__c = true
        );
        Client_Offer_Additional_Service__c oas2 = new Client_Offer_Additional_Service__c(
                Opportunity__c = opp.Id,
                Additional_Service__c = addService2.Id
        );
        Client_Offer_Additional_Service__c oas3 = new Client_Offer_Additional_Service__c(
                Additional_Service__c = addService3.Id
        );
        oasList.add(oas);
        oasList.add(oas2);
        oasList.add(oas3);
        insert oasList;

        oas3.Opportunity__c = opp.Id;
        update oas3;

        Test.startTest();
        {
            for (Client_Offer_Additional_Service__c nextClientOfferAdditionalService : [SELECT Account__c FROM Client_Offer_Additional_Service__c]) {
                System.assertEquals(account.Id, nextClientOfferAdditionalService.Account__c);
            }
        }
        Test.stopTest();
    }
}