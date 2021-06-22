({
    doInit : function(component, event, helper) {
        helper.getHistory(component, event);
    },

    reloadTable : function(component, event, helper) {
        component.set('v.loaded', false);
        helper.getHistory(component, event);
    }
})
