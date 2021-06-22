({
    doInit : function(component, event, helper) {
        var callHistoryTableHead = ['No & Type', 'Phone Number', 'Account & GFN#', 'Time', 'Duration'];
        component.set('v.callHistoryTableHead', callHistoryTableHead);
        helper.getCallHistory(component);
    },

    openAccountRecordPage : function(component, event, helper) {
        var accountId = event.target.name;
        sforce.opencti.screenPop({
            type: sforce.opencti.SCREENPOP_TYPE.SOBJECT, 
            params: { recordId: accountId }
        });
    },

    handleCall: function(component, event, helper) {
        var accountParams = event.target.name;
        if(accountParams){
            accountParams = accountParams.split(',');
        }
        var phoneNumber = accountParams[0];
        var recordId = accountParams[1];
        var eventData = { event: "ClickToDial", data: {
            number : phoneNumber,
            objectType: "Account",
            recordId: recordId,
            recordName: ""
        }};
        var compEvent = component.getEvent("CTIinfoEvent");
        compEvent.setParams({"eventData" : eventData });
        compEvent.fire();
    }
})
