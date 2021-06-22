({
    createCase : function(component) {
        var taskId = component.get("v.recordId");
        var action = component.get("c.createRelatedCase");
        action.setParams({taskId: taskId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseId = response.getReturnValue();
                var workspaceAPI = component.find("workspace");
                $A.get('e.force:refreshView').fire();
                workspaceAPI.openTab({
                    pageReference: {
                        "type": "standard__recordPage",
                        "attributes": {
                            "recordId": caseId,
                            "actionName":"view"
                        }
                    },
                    focus: true
                }).catch(function(error) {
                    console.log("error",error);
                });
            } else {
                var error = response.getError();
                if(error[0] && error[0].message){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": error[0].message
                    });
                    toastEvent.fire();
                }
            }
        })
        $A.enqueueAction(action);
    }
})