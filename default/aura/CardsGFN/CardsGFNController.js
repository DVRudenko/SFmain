({
    doInit : function(component, event, helper) {
        // var cardsTableHead = ['Card Number', 'Status', 'Card Type', 'VRN', 'Driver Name', 'Purchase Category', 'Effective date', 'Expiry date', 'Card Group', 'Odometer'];
        // component.set("v.tableHead", cardsTableHead);
        helper.getCards(component, event);
    },

    showAllCards: function(component){
        component.set("v.loaded", false);
        var allCards = component.get("v.allCards");
        component.set("v.itemList", allCards);
        component.set("v.loaded", true);
        component.set('v.isAllList', true);
    },

    getCards: function(component, event, helper){
        helper.getCards(component, event);
    },

    hideCards: function(component){
        var allCards = component.get("v.itemList");
        component.set('v.itemList', allCards.slice(0, 10));
        component.set('v.isAllList', false);
    },

    handleClickCheckbox: function(component, event, helper){
        component.set('v.isIndeterminate', false);
        var isChecked = event.currentTarget.checked;
        if(isChecked){
            helper.selectAll(component);
            component.set('v.hasSelected', true);
        }
        else{
            helper.unselectAll(component);
            component.set('v.hasSelected', false);
        }
        component.set('v.isSelectAll', isChecked);
    },

    handleSimpleCheckboxClick: function(component){
        var allChecked = []
        var allCheckboxes = component.find("checkbox");
        if(allCheckboxes){
            if(!(Array.isArray(allCheckboxes) && allCheckboxes.length)){
                allCheckboxes = [allCheckboxes];
            }
            for(var i = 0; i < allCheckboxes.length; i=i+1){
                if(allCheckboxes[i].get("v.checked")){
                    allChecked.push(allCheckboxes[i]);
                }
            }
        }
        if(allChecked.length === 0){
            component.set('v.isIndeterminate', false);
            component.set("v.isSelectAll", false);
            component.set('v.hasSelected', false);
        } else if (allChecked.length === allCheckboxes.length){
            component.set('v.isIndeterminate', false);
            component.set("v.isSelectAll", true);
            component.set('v.hasSelected', true);
        } else{
            component.set('v.isIndeterminate', true);
            component.set('v.hasSelected', true);
        }
    },

    handleAwaitingBlock: function(component, event, helper){
        component.set('v.loaded', false);
        var cardIdsString = helper.getCheckedCardIds(component);
        helper.blockCard(component, cardIdsString);
    },

    handleResendPinButton: function(component, event, helper){
        var cards = component.get("v.itemList");
        var checkedCards = [];
        for(var i = 0; i<cards.length; i=i+1){
            if(cards[i].Checked){
                checkedCards.push(cards[i]);
            }
        }
        helper.openResendPINPopup(component, event, checkedCards);        
    },

    searchCards: function(component, event, helper){
        let searchWord = component.get("v.searchWord");
        if(searchWord && searchWord != '') {
            let allCards = component.get("v.allCards");
            let filteredItems = allCards.filter((card)=>{
                return card.PAN && card.PAN.includes(searchWord);
            });
            component.set('v.itemList', filteredItems);
            component.set('v.isAllList', true);
            component.set('v.isFilteredList', true);
        }
        else {
            var allCards = component.get("v.allCards");
            component.set('v.itemList', allCards.slice(0, 10));
            component.set('v.isAllList', false);
            component.set('v.isFilteredList', false);

        }
    }
})