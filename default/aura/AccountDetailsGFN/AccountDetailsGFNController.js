({
    doInit : function(component, event, helper) {
        helper.getAccountDetails(component, event);
    },

    getAccountData : function(component, event, helper){
        helper.getAccountDetails(component, event, true);
    }
})