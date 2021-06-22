({
    getContacts : function(component, event, paramsChanged) {
        var gfnParams;
        if(paramsChanged){
            gfnParams = event.getParam("value");
        } else {
            gfnParams = component.get("v.gfnParams");
        }
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            if(gfnParams[0] && gfnParams[1]){
                var action = component.get("c.getAccountContactsGfn");
                action.setStorable();
                action.setParams({
                    "colCoID": gfnParams[0],
                    "customerNumber": gfnParams[1],
                    "lineOfBusiness" : component.get("v.lineOfBusiness")
                });
                action.setCallback(this, function(response) {
                    component.set('v.loaded', false);
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var value = response.getReturnValue();
                        if(value.AccountContacts){
                            component.set("v.contactDetails", JSON.parse(value.AccountContacts));
                            component.set("v.contactRedirectLink", value.MaintainCustomerContactLandingPage);
                        }
                        component.set("v.errorMessage", "No active Contacts")
                    }
                    else {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                this.showToast("Contact Details Error: " + errors[0].message);
                            }
                        } else {
                            this.showToast("Contact Details Error message: Unexpected error");
                        }
                        component.set("v.errorMessage", "Error")
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
    }
})