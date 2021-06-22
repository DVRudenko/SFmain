({
    getServicesData : function(component, event, paramsChanged) {
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            var params = this.prepareGFNParameters(event, gfnParams.split(','), component);
            if(params && params.colCoID && params.customerNumber){
                this.callServerMethod(
                    component,
                    "c.getAccountServicesGfn",
                    params,
                    (response)=>{
                        var returnValue = response.getReturnValue();
                        var accountServices = [];
                        var emptyListMessage = '';
                        if(returnValue.AccountServices && returnValue.AccountServices!="null"){
                            var servicesList = JSON.parse(returnValue.AccountServices);
                            for(var i = 0; i<servicesList.length; i=i+1){
                                if(servicesList[i].Registered){
                                    servicesList[i].StartDate = this.formatDate(servicesList[i].StartDate, true);
                                    accountServices.push(servicesList[i]);
                                    emptyListMessage = '';
                                }
                            }
                            if(!Array.isArray(accountServices) || !accountServices.length){
                                emptyListMessage = 'No active services';
                            }
                            if(!Array.isArray(servicesList) || !servicesList.length){
                                emptyListMessage = 'No Data';
                            }
                            component.set("v.itemList", accountServices);
                            component.set("v.emptyServiceListMessage", emptyListMessage);
                        } else {
                            component.set("v.emptyServiceListMessage", 'No Data');
                        }
                        component.set("v.landingPageLink", returnValue.MaintainServicesLandingPage);  
                        component.set('v.loaded', true);
                    },
                    (response)=>{
                        this.handleErrorState(response, 'Services', component);
                        component.set("v.emptyServiceListMessage", "Error");
                    }
                );
            } else {
                if (paramsChanged) {
                    component.set("v.emptyServiceListMessage", "Incorrect GFN Parameters");                
                }
                component.set('v.loaded', true);
            }
        } else {
            if (paramsChanged) {
                component.set("v.emptyServiceListMessage", "Incorrect GFN Parameters");                
            }
            component.set('v.loaded', true);            
        }
    }
})