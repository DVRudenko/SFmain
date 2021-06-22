({
    doInit : function(component, event, helper){
        var email = component.get("v.email");
        if(email && (!email.from || !email.to || email.from==='' || email.to === '')){
            component.set('v.validity', false);
        } else {
            component.set('v.validity', true);
        }
    },

    validateFields : function(component, event, helper) {
        var inputEmails = component.find("input-address");
        var validity = true;
        if(inputEmails && Array.isArray(inputEmails) && inputEmails.length){
            for(var i = 0; i<inputEmails.length; i=i+1){
                var currentValidity = inputEmails[i].checkValidity();
                validity = validity && currentValidity;
            }
        }
        component.set("v.validity", validity);
    }
})