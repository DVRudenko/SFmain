({
    init: function(component, event, helper) {

        var action = component.get("c.getCase");
        action.setParams({"recordId": component.get("v.recordId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var c = response.getReturnValue();
                component.set("v.case", c);
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(errors[0].message);
                    }
                } else {
                    helper.showToast("Unexpected error");
                }
                console.log('There was a problem in init: ' + errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    update: function(component, event, helper) {
        var action = component.get("c.updateCase");
        action.setParams({"caseForUpdate": component.get("v.case")});

        action.setCallback(this, function(response) {
        var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var c = response.getReturnValue();
                component.set("v.case", c);
                $A.get('e.force:refreshView').fire();
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(errors[0].message);
                    }
                } else {
                    helper.showToast("Unexpected error");
                }
                console.log('There was a problem in update: ' + errors[0].message);
            }
        });
        $A.enqueueAction(action);
    }
});