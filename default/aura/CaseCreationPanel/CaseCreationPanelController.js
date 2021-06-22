({
    changeEmailSender : function(component) {
        var newCase = component.get("v.newCase");
        component.set('v.emailSender', newCase.Queue_Email__c);
    },

    addToToField: function(component, event){
        var selectedEmailAddress = component.get("v.emailAddress");
        if(selectedEmailAddress!=""){
            component.set('v.emailTo', selectedEmailAddress);
        }
    },

    addToCcField: function(component, event){
        var selectedEmailAddress = component.get("v.emailAddress");
        if(selectedEmailAddress!=""){
            var cCEmail = component.get("v.emailCc");
            component.set('v.emailCc', selectedEmailAddress + '; ' + cCEmail);
        }
    }
})