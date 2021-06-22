({
    doInit : function(component, event, helper) {
        var relatedAccountTableHead = ['GFN Number', 'Full Name', 'Type', 'City', 'Status'];
        component.set("v.relatedAccountTableHead", relatedAccountTableHead);
    },

    openGFNDashboard: function(component, event, helper) {
        var isClassic = component.get("v.isClassic");
        var gfnParams = component.get('v.gfnParams');
        var recordId = component.get('v.recordId');
        var lineOfBusiness = component.get('v.lineOfBusiness');
        var colcoId;
        var customerNumber = event.currentTarget.text;
        if(gfnParams){
            var gfnParameters = gfnParams.split(',');
            colcoId = gfnParameters[0];
        }
        if(isClassic){
            window.open('GFNDashboardContainer?colCoId=' + colcoId + '&customerNumber=' + customerNumber + '&Id=' + recordId);
        } else {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.openSubtab({
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__GFNDashboard"
                    },
                    "state": {
                        "c__colcoId":colcoId,
                        "c__customerNumber": customerNumber,
                        "c__recordId": recordId,
                        "c__lineOfBusiness": lineOfBusiness
                    }
                },
                focus: true
            }).then(function(response) {
                workspaceAPI.setTabLabel({
                    tabId: response,
                    label: 'GFN ' + customerNumber
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
    }
})