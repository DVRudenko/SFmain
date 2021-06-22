({
    getSelfServiceData : function(component, event, offset){
        var gfnParameters = component.get("v.gfnParams");
        if(gfnParameters){
            var params = this.prepareGFNParameters(event, gfnParameters.split(','), component);
            if(params && params.colCoID && params.customerNumber){
                this.callServerMethod(
                    component,
                    "c.getAccountSelfServeUsersGfn",
                    params,
                    (response)=>{
                        component.set("v.errorMessage", "No active Self Service accounts");
                        var value = response.getReturnValue();
                        var accountList = value.AccountSelfServeUsers;
                        component.set('v.landingPageLink', value.MaintainSelfServeUserLandingPage);
                        if(accountList){
                            var resultAccList = JSON.parse(accountList);
                            if(Array.isArray(resultAccList) && resultAccList.length){
                                resultAccList = resultAccList.filter((currentAccount)=>{
                                    return currentAccount.isActive;
                                });
                                for(var acc in resultAccList){
                                    if(resultAccList[acc].LastActivity != null ){
                                        resultAccList[acc].LastActivity = this.formatDate(resultAccList[acc].LastActivity, false, offset);
                                    }
                                }
                                component.set('v.itemList', resultAccList);
                            }
                        } 
                    },
                    (response)=>{this.handleErrorState(response, "SelfService", component)}
                );
            } else {
                component.set("v.errorMessage", "Error");
                component.set('v.loaded', true);
            }
        } else{
            component.set("v.errorMessage", "Incorrect GFN parameters");
            component.set('v.loaded', true);            
        }
    },   

    resetPassword: function(component, userNameList){
        var gfnParams = component.get("v.gfnParams");
        let lineOfBusiness = component.get("v.lineOfBusiness");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            if(gfnParams[0] && gfnParams[1]){
                for(let i = 0; i< userNameList.length; i=i+1){
                    this.callServerMethod(
                        component,
                        "c.resetPassword",
                        {
                            colCoID : gfnParams[0],
                            customerNumber: gfnParams[1],
                            userName: userNameList[i],
                            lineOfBusiness : lineOfBusiness
                        },
                        (response)=>{
                            this.showInfoToast(response.getReturnValue(), 'Success', 'Success', true);
                            if(lineOfBusiness == 'CCS'){
                                this.saveLog(component, gfnParams[1], 'Success', userNameList[i]);
                            }
                        },
                        (response)=>{
                            this.handleErrorState(response, 'Reset Password', component);
                            if(lineOfBusiness == 'CCS'){
                                this.saveLog(component, gfnParams[1], 'Fail', userNameList[i]);
                            }

                        }
                    )
                }
            } else {
                this.showInfoToast('ColCoId or GFN number is empty', 'Error', 'Error', true);
            }
        } else {
            this.showInfoToast('ColCoId or GFN number is empty', 'Error', 'Error', true);
        }
    },

    getData: function(component, event) {
        this.callServerMethod(
            component,
            "c.getCurrentUserOffset",
            {},
            (response)=>{
                var offset = response.getReturnValue();
                this.getSelfServiceData(component, event, offset);
            },
            (response)=>{this.handleErrorState(response, 'Reset Password', component);}
        )
    },

    reloadResetHistoryTable : function() {
        var reloadEvent = $A.get("e.c:ReloadResetPasswordHistoryTableEvent");
        reloadEvent.setParams({"item": "test"});
        reloadEvent.fire();
    },

    saveLog : function(component, customerNumber, status, userName) {
        this.callServerMethod(
            component,
            "c.saveResetPasswortLog",
            {
                customerNumber : customerNumber,
                status : status,
                userName : userName
            },
            (response)=>{
                this.reloadResetHistoryTable();
            },
            (response)=>{this.handleErrorState(response, 'Save Log', component);}
        )
    }
})