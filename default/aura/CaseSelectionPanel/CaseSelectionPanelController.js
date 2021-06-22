({
    openCase : function(component, event, helper) {        
        var caseList = component.get("v.caseList");
        var clickedCaseId = event.currentTarget.name;
        var selectedCase = caseList.filter(function(currentCase){
            return currentCase.Id == clickedCaseId;
        });
        if(selectedCase && selectedCase[0]){
            component.set('v.selectedCase', selectedCase[0]);
            component.set('v.isSelected', true);
            var type = component.get("v.type");
            if(type == 'Resend Invoice'){
                var email = component.get("v.email");
                if(email){
                    email.from = selectedCase[0].Queue_Email__c;
                    email.to = selectedCase[0].SuppliedEmail;
                    component.set('v.email', email);
                }
            }
        }
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
    },
})