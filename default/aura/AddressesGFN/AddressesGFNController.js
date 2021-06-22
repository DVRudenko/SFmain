({
    doInit : function(component, event, helper) {
        helper.getAddresses(component, event);
    },

    getAddressParameters : function(component, event, helper){
        helper.getAddresses(component, event, true);
    }
})