({
    getAddresses : function(component, event, paramsChanged) {
        var gfnParams;
        if(paramsChanged){
            gfnParams = event.getParam("value");
        } else {
            gfnParams = component.get("v.gfnParams");
        }
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            if(gfnParams[0] && gfnParams[1]){
                var action = component.get("c.getAccountAddressesGfn");
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
                        var addressList = response.getReturnValue();
                        if(addressList.AccountAddresses){
                            var addresses = JSON.parse(addressList.AccountAddresses);
                            component.set("v.addressList", addresses);
                            component.set("v.addressRedirectLink", addressList.MaintainAddressLandingPage);
                            this.fireAddressEvent(component, event, addresses);
                        }
                        component.set("v.errorMessage", "No active Addresses");
                    }
                    else {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                this.showToast("Addresses message " + errors[0].message);
                            }
                        } else {
                            this.showToast("Addresses: Unexpected error")
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

    fireAddressEvent: function(component, event, addressList){
        var address = {};
        if(Array.isArray(addressList) && addressList.length){
            for(var i = 0; i<addressList.length; i=i+1){
                var pinDeliveryAddress = addressList[i].AddressTypes.filter((addressType)=>{
                    return addressType.AddressType == "Card Delivery" || addressType == "Pin Delivery";
                })
                if(pinDeliveryAddress && pinDeliveryAddress[0]){
                    address = {
                        AddressLines: addressList[i].AddressLines,
                        Region: addressList[i].Region,
                        ZipCode: addressList[i].ZipCode,
                        City: addressList[i].City,
                        Country: addressList[i].Country,
                    };
                }
            }
        }
        var compEvent = component.getEvent("GetPinDeliveryAddressEvent");
        compEvent.setParams({
            address: address
        });
        compEvent.fire();
    }
})