public class ClientOfferAddServiceHandler {
    public static Boolean enablesTrigger = true;


    public static void updateOpptyAdditionalServicesNames(Map<Id, Client_Offer_Additional_Service__c> clientOfeerAddServiceMap) {
        Map<Id, Opportunity> oppsMap = getOppsMap(clientOfeerAddServiceMap.values());
        Map<Id, Client_Offer_Additional_Service__c> clientOfferAdditionalServiceMap = getClientOfferAddServiceMap(oppsMap);
        Map<String, List<Client_Offer_Additional_Service__c>> oppIdToAdditionalservicesMap = new Map<String, List<Client_Offer_Additional_Service__c>>();
        for (Client_Offer_Additional_Service__c addService : clientOfferAdditionalServiceMap.values()) {
            if ( ! oppIdToAdditionalservicesMap.containsKey(addService.Opportunity__c) ) {
                oppIdToAdditionalservicesMap.put(addService.Opportunity__c, new List<Client_Offer_Additional_Service__c>());
            }
            oppIdToAdditionalservicesMap.get(addService.Opportunity__c).add(addService);
        }
        Map<Id, Additional_Service__c> addServicesMap = getAddServicesMap(clientOfferAdditionalServiceMap.values());
        String additionalServicesNames;
        for (Opportunity oppty : oppsMap.values()) {
            additionalServicesNames = null;
            if (oppIdToAdditionalservicesMap.containsKey(oppty.Id)) {
                for (Client_Offer_Additional_Service__c clientOfferAddService : oppIdToAdditionalservicesMap.get(oppty.Id)) {
                    if (addServicesMap.containsKey(clientOfferAddService.Additional_Service__c)) {
                        for (Additional_Service__c addService : addServicesMap.values()) {
                            if (additionalServicesNames == null) {
                                additionalServicesNames = addService.Type__c;
                            } else if (addService.Type__c != null && ! additionalServicesNames.contains(addService.Type__c)) {
                                additionalServicesNames = additionalServicesNames + '&'  + addService.Type__c;
                            }
                        }
                    }
                }
            }
            oppty.Additional_Services__c = additionalServicesNames;
        }

        OpportunityTriggerHandler.enablesTrigger = false;
        update oppsMap.values();
        OpportunityTriggerHandler.enablesTrigger = true;
    }


    public static void addAdditionalServicesToOpp(Map<Id, Client_Offer_Additional_Service__c> newMap) {
        Map<Id, Opportunity> oppsMap = getOppsMap(newMap.values());
        Map<Id, Additional_Service__c> addServicesMap = getAddServicesMap(newMap.values());
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        for (Client_Offer_Additional_Service__c oas : newMap.values()) {
            Opportunity opp = oppsMap.get(oas.Opportunity__c);
            if (opp != null) {
                Additional_Service__c addServices = addServicesMap.get(oas.Additional_Service__c);
                if (addServices.Type__c == 'Eco Fee') {
                    if (oppsToUpdate.containsKey(opp.Id)) {
                        oppsToUpdate.get(opp.Id).Eco_Fee__c = oas.Selected__c;
                    } else {
                        opp.Eco_Fee__c = oas.Selected__c;
                        oppsToUpdate.put(opp.Id, opp);
                    }
                }
                else if (addServices.Type__c == 'Paper Invoice') {
                    if (oppsToUpdate.containsKey(opp.Id)) {
                        oppsToUpdate.get(opp.Id).Papierrechnung__c = oas.Selected__c;
                    } else {
                        opp.Papierrechnung__c = oas.Selected__c;
                        oppsToUpdate.put(opp.Id, opp);
                    }
                }
                else if (addServices.Type__c == 'VAT Refund') {
                    if (oppsToUpdate.containsKey(opp.Id)) {
                        oppsToUpdate.get(opp.Id).VAT_Recovery__c = oas.Selected__c;
                        oppsToUpdate.get(opp.Id).Agree_to_VAT_Recovery_TC__c = oas.Selected__c;
                        if (oas.Selected__c) {
                            oppsToUpdate.get(opp.Id).Date_of_Acceptance_VAT_Recovery_TC__c = Datetime.now();
                        } else {
                            oppsToUpdate.get(opp.Id).Date_of_Acceptance_VAT_Recovery_TC__c = null;
                        }
                    } else {
                        opp.VAT_Recovery__c = oas.Selected__c;
                        opp.Agree_to_VAT_Recovery_TC__c = oas.Selected__c;
                        if (oas.Selected__c) {
                            opp.Date_of_Acceptance_VAT_Recovery_TC__c = Datetime.now();
                        } else {
                            opp.Date_of_Acceptance_VAT_Recovery_TC__c = null;
                        }
                        oppsToUpdate.put(opp.Id, opp);
                    }
                }
            }
        }
        if ( ! oppsToUpdate.isEmpty() ) {
            update oppsToUpdate.values();
        }
    }


    public static void removeAdditionalServicesToOpp(List<Client_Offer_Additional_Service__c> oldList) {
        Map<Id, Opportunity> oppsMap = getOppsMap(oldList);
        Map<Id, Additional_Service__c> addServicesMap = getAddServicesMap(oldList);
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        for (Client_Offer_Additional_Service__c oas : oldList) {
            Opportunity opp = oppsMap.get(oas.Opportunity__c);
            if (opp != null) {
                Additional_Service__c addServices = addServicesMap.get(oas.Additional_Service__c);
                if (addServices.Type__c == 'Eco Fee') {
                    if (oppsToUpdate.containsKey(opp.Id)) {
                        oppsToUpdate.get(opp.Id).Eco_Fee__c = false;
                    } else {
                        opp.Eco_Fee__c = false;
                        oppsToUpdate.put(opp.Id, opp);
                    }
                }
                else if (addServices.Type__c == 'Paper Invoice') {
                    if (oppsToUpdate.containsKey(opp.Id)) {
                        oppsToUpdate.get(opp.Id).Papierrechnung__c = false;
                    } else {
                        opp.Papierrechnung__c = false;
                        oppsToUpdate.put(opp.Id, opp);
                    }
                }
                else if (addServices.Type__c == 'VAT Refund') {
                    if (oppsToUpdate.containsKey(opp.Id)) {
                        oppsToUpdate.get(opp.Id).VAT_Recovery__c = false;
                        oppsToUpdate.get(opp.Id).Agree_to_VAT_Recovery_TC__c = false;
                        oppsToUpdate.get(opp.Id).Date_of_Acceptance_VAT_Recovery_TC__c = null;
                    } else {
                        opp.VAT_Recovery__c = false;
                        opp.Agree_to_VAT_Recovery_TC__c = false;
                        opp.Date_of_Acceptance_VAT_Recovery_TC__c = null;
                        oppsToUpdate.put(opp.Id, opp);
                    }
                }
            }
        }
        if ( ! oppsToUpdate.isEmpty() ) {
            update oppsToUpdate.values();
        }
    }


    private static Map<Id, Client_Offer_Additional_Service__c> getClientOfferAddServiceMap(Map<Id, Opportunity> oppsMap) {
        return new Map<Id, Client_Offer_Additional_Service__c>([SELECT Selected__c, Additional_Service__c, Opportunity__c FROM Client_Offer_Additional_Service__c WHERE Opportunity__c IN :oppsMap.keySet() AND Selected__c = TRUE]);
    }


    private static Map<Id, Additional_Service__c> getAddServicesMap(List<Client_Offer_Additional_Service__c> oppsAddServicesList) {
        Set<Id> addServicesIdsSet = new Set<Id>();
        for (Client_Offer_Additional_Service__c oas : oppsAddServicesList) {
            addServicesIdsSet.add(oas.Additional_Service__c);
        }

        if (addServicesIdsSet.isEmpty()) {
            return null;
        }
        Map<Id, Additional_Service__c> addServicesMap = new Map<Id, Additional_Service__c>([
                SELECT Name, Type__c
                FROM Additional_Service__c
                WHERE Id IN :addServicesIdsSet
        ]);

        return addServicesMap;
    }


    private static Map<Id, Opportunity> getOppsMap(List<Client_Offer_Additional_Service__c> oppsAddServicesList) {
        Set<Id> oppIdsSet = new Set<Id>();
        for (Client_Offer_Additional_Service__c oas : oppsAddServicesList) {
            oppIdsSet.add(oas.Opportunity__c);
        }

        if (oppIdsSet.isEmpty()) {
            return null;
        }
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([
                SELECT Id
                FROM Opportunity
                WHERE Id IN :oppIdsSet
        ]);

        return oppsMap;
    }


    public static void prefillAccountLookup (List<Client_Offer_Additional_Service__c> newList, Map<Id, Client_Offer_Additional_Service__c> oldMap) {
        Set<String> opportunitiesIds = new Set<String>();
        List<Client_Offer_Additional_Service__c> entriesForPrefilling = new List<Client_Offer_Additional_Service__c>();
        for (Client_Offer_Additional_Service__c next : newList) {
            if ((next.Account__c == null && next.Opportunity__c != null) ||
                (oldMap != null && next.Opportunity__c != oldMap.get(next.Id).Opportunity__c))
            {
                opportunitiesIds.add(next.Opportunity__c);
                entriesForPrefilling.add(next);
            }
        }
        Map<String, Opportunity> opportunitiesByIds = new Map<String, Opportunity>([
                SELECT  AccountId
                FROM    Opportunity
                WHERE   Id IN : opportunitiesIds
        ]);
        for (Client_Offer_Additional_Service__c next : entriesForPrefilling) {
            next.Account__c = null;
            Opportunity opportunityForNextEntry = opportunitiesByIds.get(next.Opportunity__c);
            if (opportunityForNextEntry != null) {
                next.Account__c = opportunityForNextEntry.AccountId;
            }
        }
    }
}