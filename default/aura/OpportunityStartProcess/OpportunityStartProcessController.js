({
    doInit : function(component, event, helper) {
        var action = component.get('c.getListOfReadFields');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                component.set('v.pageReadFields', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);

        var action = component.get('c.getListOfEditFields');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                component.set('v.pageEditFields', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    handleLoad : function(component, event, helper) {
        component.set('v.showSpinner', false);
    },

    handleSubmit : function(component, event, helper) {
        component.set('v.showSpinner', true);
    },

    handleError : function(component, event, helper) {
        // errors are handled by lightning:inputField and lightning:nessages
        // so this just hides the spinnet
        component.set('v.showSpinner', false);
    },

    handleSuccess : function(component, event, helper) {
        component.set('v.showSpinner', false);
        component.set('v.mode','Read');
    },

    editFormHandler : function(component, event, helper){
        component.set('v.showSpinner', true);
        component.set('v.mode','Edit');
    },

    cancelEditing : function(component, event, helper){
        component.set('v.mode','Read');
    }
})