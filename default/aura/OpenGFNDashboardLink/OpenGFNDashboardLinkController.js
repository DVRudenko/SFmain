({
    openTab: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var objectName = component.get('v.sObjectName');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__GFNDashboard"
                },
                "state": {
                    "c__recordId":recordId,
                    "c__objectName": objectName
                }
            },
            focus: true
        }).then(function(response) {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: 'GFN Dashboard'
            }).then(function(){
                workspaceAPI.setTabIcon({
                    tabId: response,
                    icon: 'standard:screen',
                    iconAlt: 'i'
                });
            });
        }).catch(function(error) {
            console.log("error"+error);
        });
    }
})