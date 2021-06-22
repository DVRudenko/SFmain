({

    doInit : function(component, event, helper) {
        var colCoValues = [
            {colCoId: '2', value: 'AT'},
            {colCoId: '3', value: 'BE'},
            {colCoId: '80', value: 'CH'},
            {colCoId: '81', value: 'CZ'},
            {colCoId: '1', value: 'DE'},
            {colCoId: '5', value: 'FR'},
            {colCoId: '6', value: 'HU'},
            {colCoId: '79', value: 'LU'},
            {colCoId: '4', value: 'NL'},
            {colCoId: '7', value: 'PL'},
            {colCoId: '82', value: 'SK'},
            {colCoId: '8', value: 'CCS CZ'},
            {colCoId: '9', value: 'CCS SK'},
        ];
        component.set('v.colCoValues', colCoValues);
    },

    searchInGFN : function(component, event, helper) {
        helper.searchInGFN(component);
    },

    openGFNDashboard: function(component, event, helper) {
        var customerNumber = event.currentTarget.name;
        var lineOfBusiness = event.currentTarget.dataset.lob;
        var colCoId = event.currentTarget.dataset.colco;
        console.log('colCo', colCoId);
        console.log('customerNumber', customerNumber);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__GFNDashboard"
                },
                "state": {
                    "c__colcoId":colCoId,
                    "c__customerNumber": customerNumber,
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
})