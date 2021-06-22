({

    handleCards: function(cardList, changedCards, component){
        var resultCardList = [];
        var blockedCards = [];
        var isArrayValid = false;
        let lob =  component.get("v.lineOfBusiness");
        if(changedCards){
            blockedCards = JSON.parse(changedCards);
            isArrayValid = Array.isArray(blockedCards) && blockedCards.length;
            
        }
        if(cardList && Array.isArray(cardList) && cardList.length){
            for(var i = 0; i<cardList.length; i = i+1){
                var expiredDate = this.addDays(new Date(cardList[i].ExpiryDate), 60);
                var blockedDate = this.addDays(new Date(cardList[i].LastStatusChange), 60);
                if(!((cardList[i].Status === "Expired" && Date.now()> expiredDate && lob=='SME') || (cardList[i].Status === "Blocked Card" && Date.now()> blockedDate)
                    || (cardList[i].Status === "Expired and cancelled" && Date.now() > expiredDate && lob=='SME') || (cardList[i].Status === "Cancelled" && Date.now() > blockedDate)
                    || (cardList[i].Status === "Expired and cancelled" && lob=='CCS') || (cardList[i].Status === "Expired" && lob=='CCS'))) {
                    if(cardList[i].IsOdometerPromptRequired){
                        cardList[i].IsOdometerPromptRequired = "Yes";
                    } else {
                        cardList[i].IsOdometerPromptRequired = "No";
                    }
                    cardList[i].Checked = false;
                    cardList[i].EffectiveDate = this.formatDate(cardList[i].EffectiveDate, true);
                    cardList[i].ExpiryDate = this.formatDate(cardList[i].ExpiryDate, true);
                    resultCardList.push(cardList[i]);
                }
                var currentCard = blockedCards.filter((item) => {
                    return (item.cardId === cardList[i].CardID);
                })
                if(isArrayValid && currentCard && currentCard[0]){
                    if(currentCard[0].previousStatus === cardList[i].Status) {
                        cardList[i].Status = 'Awaiting Block';
                        if ( cardList[i].CardType=='Lotos Biznes' || cardList[i].CardType.includes('EV-') ) {
                            cardList[i].Status = 'Pending block';
                        }
                        if (lob == 'CCS') {
                            cardList[i].Status = 'Blocked card ';
                        }
                    } else {
                        var gfnParams = component.get("v.gfnParams");
                        this.setCookie(gfnParams+'cardIds', "", 0);
                    }
                }
            }
        }
        return resultCardList;
    },

    getCards: function(component, event){                
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            var gfnParameters = gfnParams.split(',');
            var ignoreExisting = this.getCookie(gfnParams+'ignoreExisting');
            var changedCards = this.getCookie(gfnParams+'cardIds');
            var params = this.prepareGFNParameters(event, gfnParameters, component);
            if(params && params.colCoID && params.customerNumber){
                this.callServerMethod(
                    component,
                    "c.getAccountCardsInfoGfn",
                    params,
                    (response)=>{
                        component.set("v.errorMessage", "No Cards to be displayed");
                        var result = response.getReturnValue();
                        component.set('v.landingPageLink', result.MaintenanceCardsLandingPage);
                        component.set('v.orderNewCard', result.CardCreationLandingPage);
                        if(result.AccountCardsInfo && result.AccountCardsInfo != "null"){
                            var cardList = JSON.parse(result.AccountCardsInfo);
                            cardList = this.handleCards(cardList, changedCards, component);
                            component.set('v.allCards', cardList);
                            component.set('v.itemList', cardList.slice(0,10));
                        }
                    },
                    (response)=>{
                        this.handleErrorState(response, 'Cards', component);
                    },
                    ignoreExisting
                )
            } else {
                component.set('v.loaded', true);
                component.set("v.errorMessage", "Incorrect GFN parameters");
            }
        } else {
            component.set('v.loaded', true);
            component.set("v.errorMessage", "Incorrect GFN parameters");           
        }
    },

    addDays: function(date, days) {
        const copy = new Date(Number(date));
        copy.setDate(date.getDate() + days);
        return copy;
      },

    selectAll: function(component, event, helper){
        var allCheckboxes = component.find("checkbox");
        if(allCheckboxes){
            if(Array.isArray(allCheckboxes) && allCheckboxes.length){
                for(var i = 0; i < allCheckboxes.length; i=i+1){
                    allCheckboxes[i].set("v.checked", true);
                }
            } else{
                allCheckboxes.set("v.checked", true);
            }
        }
    },

    unselectAll: function(component, event, helper){
        var allCheckboxes = component.find("checkbox");
        if(allCheckboxes){
            if(Array.isArray(allCheckboxes) && allCheckboxes.length){
                for(var i = 0; i < allCheckboxes.length; i=i+1){
                    allCheckboxes[i].set("v.checked", false);
                }
            } else{
                allCheckboxes.set("v.checked", false);
            }
        }
    },

    blockCard: function(component, cardIds){
        var gfnParameters = component.get("v.gfnParams");
        if(gfnParameters){
            var gfnParams = gfnParameters.split(",");
            var params = {
                colCoID: gfnParams[0],
                customerNumber: gfnParams[1],
                cardIdsList: cardIds,
                lineOfBusiness: component.get("v.lineOfBusiness")
            }
            this.callServerMethod(
                component,
                "c.blockAccountCardsGfn",
                params,
                (response)=>{
                    var returnValue = response.getReturnValue();
                    if(returnValue.BlockCardRequests){
                        var value = JSON.parse(returnValue.BlockCardRequests);
                        var succsessCards = this.handleResponse(component, value);
                        this.setCookie(gfnParameters+'ignoreExisting', 'true',1);
                        this.setCookie(gfnParameters+"cardIds", succsessCards);
                    }
                },
                (response)=>{
                    this.handleErrorState(response, 'Awaiting block');
                },
                true
            )
        } else {
            this.showInfoToast('Incorrect GFN Parameters', 'Error', 'Error', true);
            component.set('v.loaded', true);
        }
    },

    showPopup: function(successList, errors){
        var errorMessage = '';
        for(var error in errors){
            errorMessage = errorMessage+error + ': '+ errors[error].join(', ')+" \n";
        }
        if(successList.length){
            this.showInfoToast(successList.join(', '), "success", "Success!", true);
        }
        if(errorMessage || errorMessage.trim()===''){
            this.showInfoToast(errorMessage, "error", "Error!", true);
        }
    },

    handleResponse: function(component, response){
        var changedCards = this.getCookie(component.get("v.gfnParams")+'cardIds');
        var successList = [];
        var listToSave = [];
        var errors = {};
        var itemList = component.get("v.itemList");
        let lob =  component.get("v.lineOfBusiness");
        if(changedCards){
            listToSave = JSON.parse(changedCards);
        }
        if(Array.isArray(response) && response.length){
            for(var i=0; i<response.length; i=i+1){
                var currentCard = itemList.filter((item) => {
                    return item.CardID === response[i].CardID
                })
                if(response[i].BlockRequested){
                    successList.push(currentCard[0].PAN);
                    listToSave.push({
                        cardId: response[i].CardID,
                        previousStatus: currentCard[0].Status,
                        CardType: currentCard[0].CardType
                    });
                    currentCard[0].Status = 'Awaiting Block';
                    if ( currentCard[0].CardType=='Lotos Biznes' || currentCard[0].CardType.includes('EV-') ) {
                        currentCard[0].Status = 'Pending block';
                    }
                    if (lob == 'CCS') {
                        currentCard[0].Status = 'Blocked card ';
                    }
                } else {
                    var cardsWithError = errors[response[i].Error];
                    if(cardsWithError && Array.isArray(cardsWithError)){
                        cardsWithError.push(currentCard[0].PAN.slice(-4));
                        errors[response[i].Error] = cardsWithError;
                    } else {
                        errors[response[i].Error] = [currentCard[0].PAN.slice(-4)];
                    }
                }
            }
        }
        this.showPopup(successList, errors);
        component.set('v.itemList', itemList);
        return JSON.stringify(listToSave);
    },

    getCheckedCardIds: function(component){
        var cards = component.get("v.itemList");
        var cardIds = [];
        for(var i = 0; i<cards.length; i=i+1){
            if(cards[i].Checked){
                cardIds.push(cards[i].CardID);
            }
        }
        var cardIdsString = cardIds.join(', ');
        return cardIdsString;
    },

    openResendPINPopup: function(component, event, checkedCards){
        var compEvent = component.getEvent("ResendInvoiceButtonEvent");
        compEvent.setParams({
            "isResendInvoicePopupOpened":true,
            "popupType": "Resend PIN",
            "cards": checkedCards
        });
        compEvent.fire();
    }
})