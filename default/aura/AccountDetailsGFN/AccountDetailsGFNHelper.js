({
    getAccountDetails : function(component, event, paramsChanged) {
        var gfnParams;
        if(paramsChanged){
            gfnParams = event.getParam("value");
        } else {
            gfnParams = component.get("v.gfnParams");
        }
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            if(gfnParams[0] && gfnParams[1]){
                var action = component.get("c.getAccountDetailsGfn");
                action.setStorable();
                action.setParams({
                    "colCoID": gfnParams[0],
                    "customerNumber": gfnParams[1],
                    "lineOfBusiness": component.get("v.lineOfBusiness")
                });
                action.setCallback(this, function(response) {
                    component.set('v.loaded', false);
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        this.handleSuccessCallBack(response, component);
                        var language = response.getReturnValue().Lang;
                        var companyName = response.getReturnValue().FullName;
                        if(language){
                            var compEvent = component.getEvent("ChangeAccParamsEvent");
                            compEvent.setParams({
                                accParams:language+','+gfnParams[0],
                                companyName: companyName
                            });
                            compEvent.fire();
                        }
                    }
                    else {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                this.showToast("Account Details Error message: " + errors[0].message);
                            }
                        } else {
                            this.showToast("Account Details Error message: Unexpected error");
                        }
                        component.set("v.errorMessage", "Error");
                    }
                    component.set('v.loaded', true);
                });
                $A.enqueueAction(action);
            } else {
                component.set('v.loaded', true);
                if(paramsChanged){
                    component.set("v.errorMessage", "Incorrect GFN Parameters");
                }
            }
        } else {
            component.set('v.loaded', true);
            if(paramsChanged){
                component.set("v.errorMessage", "Incorrect GFN Parameters");   
            }        
        }
    },
     
    getParameterNames: function(){
        return {
            "FullName": "Full Name",
            "Status": "CUSTOMER STATUS",
            "GfnNum": "GFN Number",
            "RegNum": "Registration Number",
            "Vat": "VAT Number",
            "Lang": "Language",
            "MarketSegment": "Marketing Segment.",
            "LineOfBusiness": "Line Of Business",
            "CustomerClassification": "Customer Classification",
            "AvgVolume": "Average Volume",
            "DebtorStatus": "Debtor Status",
            "AccountType": "Type",
            "StartDate": "Start Date"
        };
    },

    getPriorityMap: function(){
        return {
            "FullName": 1,
            "AvgVolume": 2,
            "GfnNum": 3,
            "MarketSegment": 4,
            "LineOfBusiness": 5,
            "CustomerClassification": 6,
            "Status": 7,
            "Lang": 8,
            "StartDate": 9,
            "RegNum": 10,
            "AccountType": 11,
            "Vat": 12,
            "DebtorStatus": 13
        };
    },

    handleSuccessCallBack: function(response, component){
        var accountDetails = [];
        var parameterNames = this.getParameterNames();
        var priorityMap = this.getPriorityMap();
        var returnValue = response.getReturnValue();
        returnValue['AvgVolume'] = Number(returnValue['AvgVolume']).toFixed(2) + ' L';
        returnValue['StartDate'] = $A.localizationService.formatDate(returnValue['StartDate'], "dd/MM/yyyy");
        for(var value in returnValue){
            if(value === "RelatedAccounts"){
                if(returnValue[value]){
                    var relatedAccountList = JSON.parse(returnValue[value]);
                    if(relatedAccountList && Array.isArray(relatedAccountList)){
                        this.prepareRelatedAccounts(component, relatedAccountList);
                    }
                }
            } else if(value === 'MaintainCustomerLandingPage'){
                component.set("v.redirectAccountLink", returnValue[value]);
            } else if(value === 'CustomerStatusLandingPage'){
                component.set("v.changeStatusLink", returnValue[value]);
            } else{
                accountDetails.push(
                    {
                        "name": parameterNames[value],
                        "value": returnValue[value],
                        "priority": priorityMap[value],
                        "isLotosLob": parameterNames[value] == 'Line Of Business' && returnValue[value] && returnValue[value].includes('Lotos')
                    }
                );
            }
        }
        accountDetails.sort(function(a, b){
            return a.priority - b.priority;
        });
        component.set("v.accountDetails", accountDetails);       
    },

    showToast: function(message){
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": message
            });
            toastEvent.fire();            
        } catch (error) {
            alert(message);
        }
    },

    prepareRelatedAccounts: function(component, relatedAccounts){
        var relatedAccountList = [];
        for(var i = 0; i< relatedAccounts.length; i=i+1){
            if(relatedAccounts[i].Status == 'Active'){
                relatedAccountList.push(relatedAccounts[i]);
            }
        }
        relatedAccountList.sort(function(a, b){
            if(a.Parent){ 
                return -1;
            } else if (b.Parent){
                return 1;
            }
            else{
                return 0;
            }
        });
        component.set("v.relatedAccountList", relatedAccountList);
    }
})