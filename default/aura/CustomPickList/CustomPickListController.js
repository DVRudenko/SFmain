({
    doInit : function(component, event, helper) {
        helper.getPickListValues(component);
    },

    changeSelectedValue : function(component,event, helper) {
        component.set('v.selectedValue', component.find("picklist").get("v.value"));
    },

    handleDependentFieldChange : function(component, event, helper) {
        helper.getPickListValues(component);
    },

    handleRecordTypeIdChange : function(component, event, helper) {
        helper.getPickListValues(component);
    }
})
