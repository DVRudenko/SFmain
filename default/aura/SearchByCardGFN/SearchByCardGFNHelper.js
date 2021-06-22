({
    ERROR_MESSAGE : 'Invalid card number or ColCo',

    searchInGFN : function(component) {
        var cardNumber = component.get("v.cardNumber");
        var colCo = component.get("v.colCo");
        console.log('colco', colCo);
        if(colCo == "" || !cardNumber || cardNumber.length != 6){
            this.showToast("Please select Country Code and enter 6 digits in input field");
        }
        else {
            colCo = colCo.split(' ');
            if(colCo.length == 2 && colCo[0] == 'CCS') {
                this.getAccountList(component, cardNumber, colCo[1], 'CCS');
            }
            else {
                this.getAccountList(component, cardNumber, colCo[0], 'SME');
            }
            component.set('v.errorMessage', null);
        }
    },

    getAccountList :function(component, cardNumber, colCoId, lineOfBusiness) {
        component.set('v.smeLoaded', false);
        component.set('v.accountList', null);
        var action = component.get("c.getAccountsByPan");
        action.setParams({
            cardNumber: cardNumber,
            colCo: colCoId,
            lineOfBusiness: lineOfBusiness
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var accParams = response.getReturnValue();
                if(accParams){
                    var accParamsList = JSON.parse(accParams.Accounts);
                    var accountByPans = [];
                    if(accParamsList && accParamsList.Data) {
                        accountByPans = this.deduplicate(accParamsList.Data.AccountByPANs);
                        if(lineOfBusiness === 'CCS') {
                            accountByPans = this.filterByCountry(colCoId, accountByPans);
                        }
                        for (let i = 0; i < accountByPans.length; i++) {
                            accountByPans[i].lob = lineOfBusiness;
                            accountByPans[i].colCoId = accParams.colCoId;
                        }
                        component.set('v.accountList', accountByPans);
                    }
                    if(!accountByPans || accountByPans.length < 1) {
                        // this.showToast(this.ERROR_MESSAGE);
                        component.set('v.errorMessage', this.ERROR_MESSAGE);

                    }
                } else {
                    // this.showToast(this.ERROR_MESSAGE);
                    component.set('v.errorMessage', this.ERROR_MESSAGE);

                }
                component.set('v.loaded', true);
                this.handleError(component);
            } else {
                this.getErrorMessage(component, response);
                this.handleError(component);
            }
        })
        $A.enqueueAction(action);
    },

    showToast : function(message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": message
        });
        toastEvent.fire();
    },

    deduplicate: function(accounts){
        var deduplicatedArray = [];
        for(let i = 0; i < accounts.length; i++) {
            var account = accounts[i];
            var existingAccounts = deduplicatedArray.filter((acc)=>{
                return acc.CustomerERP == account.CustomerERP;
            });
            if(existingAccounts.length == 0) {
                deduplicatedArray.push(account);
            }
        }
        return deduplicatedArray;
    },

    handleError : function(component) {
        let loaded = component.get("v.loaded");
        // let ccsLoaded = component.get("v.ccsLoaded");
        let errorMessage = component.get("v.errorMessage");
        let smeList =  component.get("v.accountList");
        if(loaded && (!smeList || smeList.length == 0) && errorMessage) {
            this.showToast(errorMessage);
        }
    },

    getErrorMessage : function(component, response) {
        console.log('error: ', response.getError());
        var errorMessage = response.getError()[0].message;
        if(errorMessage && errorMessage.includes('404')){
            // this.showToast(this.ERROR_MESSAGE);
            component.set('v.errorMessage', this.ERROR_MESSAGE);
        } else {
            // this.showToast(errorMessage);
            component.set('v.errorMessage', errorMessage);
        }
        component.set('v.loaded', true);
    },

    filterByCountry : function(colCoId, accountByPans) {
        let filteredAccounts = [];
        for(let i = 0; i < accountByPans.length; i++) {
            if(colCoId === 'CZ' && (accountByPans[i].CardType.includes('CZ') || accountByPans[i].CardType.includes('Czech'))) {
                filteredAccounts.push(accountByPans[i]);
            }
            else if(colCoId === 'SK' && (accountByPans[i].CardType.includes('SK') || accountByPans[i].CardType.includes('Slovakia'))) {
                filteredAccounts.push(accountByPans[i]);
            }
        }
        return filteredAccounts;
    }


})