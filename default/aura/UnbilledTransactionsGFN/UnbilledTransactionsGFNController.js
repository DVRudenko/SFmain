({
    doInit : function(component, event, helper) {
        helper.getProductList(component, event);
        helper.getTransactions(component, event);
    },

    getTransactions: function(component, event, helper){
        helper.getTransactions(component, event);
    },

    showAllTransactions: function(component){
        component.set("v.loaded", false);
        var allCards = component.get("v.searchResults");
        component.set("v.itemList", allCards);
        component.set("v.loaded", true);
        component.set('v.isAllList', true);
    },

    hideTransactions: function(component){
        var allCards = component.get("v.itemList");
        component.set('v.itemList', allCards.slice(0, 10));
        component.set('v.isAllList', false);
    },

    search: function(component,event, helper){
        var dateFromField = component.find("dateFrom").get("v.value");
        var dateToField = component.find("dateTo").get("v.value");
        var cardNumberField = component.find("cardNumber").get("v.value");
        var producrField = component.find("product").get("v.value");
        var allTransactions = component.get("v.allTransactions");
        var searchResult = [];
        for(var i = 0; i < allTransactions.length; i=i+1){
            if(helper.isSearchResult(allTransactions[i], dateFromField, dateToField, cardNumberField, producrField)){
                searchResult.push(allTransactions[i]);
            }
        }
        component.set('v.itemList', searchResult.slice(0, 10));
        component.set('v.searchResults', searchResult);
        component.set('v.isAllList ', false);
    }
})