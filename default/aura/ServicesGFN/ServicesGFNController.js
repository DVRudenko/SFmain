({
    doInit : function(component, event, helper) {
        helper.getServicesData(component, event);
    },

    getServices : function(component, event, helper){
        helper.getServicesData(component, event, true);
    }
})