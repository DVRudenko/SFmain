global class FieldSalesPresentationCtrl {

    public String presentationType {get;set;}
    public String eventId {get; set;}
    public String companyName {get; set;}
    public String currentProvider {get; set;}
    public String inn {get; set;}
    public String bank {get; set;}
    public String region {get; set;}
    public Decimal vehicles {get; set;}
    public Decimal cards {get; set;}
    public String shippingAddress {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public String chosenTariff {get; set;}

    public void init(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        if(params.containsKey('type')){
            presentationType = params.get('type');
        } else {
            String currentUserId = UserInfo.getUserId();
            List<User> currentUser = [SELECT Id, UserRole.Name FROM User WHERE Id = :currentUserId];
            if(currentUser.get(0).UserRole.Name.contains('PPR')){
                presentationType = 'PPR';
            } else if(currentUser.get(0).UserRole.Name.contains('GPC')){
                presentationType = 'GPC';
            } else {
                presentationType = 'PPR';
            }
        }

        eventId = ApexPages.currentPage().getParameters().get('eventId');
        if(eventId != null && eventId != '') {
            List<Event> currentEvent = [
                    SELECT id, Description, WhatId, WhoId
                    FROM Event
                    WHERE Id = :eventId
            ];
            if(currentEvent.size() != 0){
                if(currentEvent.get(0).WhoId != null && String.valueOf(currentEvent.get(0).WhoId).startsWith('00Q')){
                    List<Lead> currentLead = [
                            SELECT Id, INN__c, Bank__c, Region__c, Number_of_Vehicles__c, ALL_Cards_BB__c, Email, Phone,
                                    Country, Postalcode, State, City, Street
                            FROM Lead
                            WHERE Id = :currentEvent.get(0).WhoId
                    ];
                    if(currentLead.size() != 0){
                        inn = currentLead.get(0).INN__c;
                        bank =  currentLead.get(0).Bank__c;
                        region =  currentLead.get(0).Region__c;
                        vehicles =  currentLead.get(0).Number_of_Vehicles__c;
                        cards =  currentLead.get(0).ALL_Cards_BB__c;
                        shippingAddress =  currentLead.get(0).country + currentLead.get(0).postalCode +
                                           currentLead.get(0).State + currentLead.get(0).city + currentLead.get(0).Street;
                        email = currentLead.get(0).Email;
                        phone = currentLead.get(0).Phone;
                    }
                }
                else if(currentEvent.get(0).WhatId != null && String.valueOf(currentEvent.get(0).WhatId).startsWith('006')){
                    List<Opportunity> currentOpportunity = [
                            SELECT Id, Account.INN__c, Account.Bank__c, Account.Region__c, Number_of_Vehicles__c, Number_of_Cards__c, Account.Name,
                                    Primary_Fueling_Method_specific__c, Product_PPR__c,
                                            Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingCity, Account.ShippingStreet
                            FROM Opportunity
                            WHERE Id = :currentEvent.get(0).WhatId
                    ];
                    if(currentOpportunity.size() != 0){
                        companyName = currentOpportunity.get(0).Account.Name;
                        currentProvider = currentOpportunity.get(0).Primary_Fueling_Method_specific__c;
                        inn = currentOpportunity.get(0).Account.INN__c;
                        bank =  currentOpportunity.get(0).Account.Bank__c;
                        region =  currentOpportunity.get(0).Account.Region__c;
                        vehicles =  currentOpportunity.get(0).Number_of_Vehicles__c;
                        cards =  currentOpportunity.get(0).Number_of_Cards__c;
                        shippingAddress =  GlobalUtils.blankStringIfNull(currentOpportunity.get(0).Account.ShippingCountry) +
                                           GlobalUtils.blankStringIfNull(currentOpportunity.get(0).Account.ShippingPostalCode) +
                                           GlobalUtils.blankStringIfNull(currentOpportunity.get(0).Account.ShippingState) +
                                           GlobalUtils.blankStringIfNull(currentOpportunity.get(0).Account.ShippingCity) +
                                           GlobalUtils.blankStringIfNull(currentOpportunity.get(0).Account.ShippingStreet);
                        chosenTariff = currentOpportunity.get(0).Product_PPR__c;
                        List<Contact> currentContact = [
                                SELECT Id, Email, Phone
                                FROM Contact
                                WHERE AccountId = :currentOpportunity.get(0).AccountId LIMIT 1
                        ];
                        if(currentContact.size() != 0){
                            email = currentContact.get(0).Email;
                            phone = currentContact.get(0).Phone;
                        }
                    }
                }
            }
        }
    }

    @RemoteAction
    global static void saveComment(String comment, String eventId){
        if(eventId != null && eventId != ''){
            List<Event> eventToUpdate = [SELECT Id, Description FROM Event WHERE  Id = :eventId];
            if(eventToUpdate.size() != 0){
                Event currentEvent = eventToUpdate.get(0);
                String newDescription = '';
                if(currentEvent.Description != null && !currentEvent.Description.startsWith('----- Комментарии к презентации -----')){
                    if(currentEvent.Description.contains('\n----- Комментарии к презентации -----')){
                        newDescription = currentEvent.Description.substringBefore('\n----- Комментарии к презентации -----');
                    } else  {
                        newDescription = currentEvent.Description;
                    }
                }
                newDescription += comment;
                currentEvent.Description = newDescription;
                update currentEvent;
            }
        }
    }

}