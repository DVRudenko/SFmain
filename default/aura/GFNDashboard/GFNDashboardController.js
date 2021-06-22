({
    doInit: function(component, event, helper) {
        var isClassic = component.get("v.isClassic");
        var params = component.get('v.gfnParams');
        if(isClassic && (!params || params.includes('undefined'))) {
            helper.showToast('ColCo or GFN Number is empty');
        }
        
        if(!isClassic) {
            var pageReference = component.get("v.pageReference");
            var recordId = '';
            var objectName = '';
            var colCoId = '';
            var customerNumber = '';
            var lineOfBusiness = '';
            if(pageReference && pageReference.state){
                recordId = pageReference.state.c__recordId;
                objectName = pageReference.state.c__objectName;
                colCoId = pageReference.state.c__colcoId;
                customerNumber = pageReference.state.c__customerNumber;
                lineOfBusiness = pageReference.state.c__lineOfBusiness;
            }
            if(recordId && objectName){
                component.set("v.objectName", objectName);
                component.set("v.recordId", recordId);
                helper.getGfnParameters(component, recordId, objectName);
            } else if (colCoId && customerNumber){
                var gfnParams = colCoId + ',' + customerNumber;
                component.set("v.gfnParams", gfnParams);
                component.set("v.recordType", lineOfBusiness);
                helper.getUISettingsAndOpenDashboard(component);
            }
        } else {
            helper.getUISettingsAndOpenDashboard(component);
        }
    },

    openTab: function(component, event, helper){
        var globalId = component.getGlobalId();
        var parentElement = event.currentTarget.parentElement;
        var currentTabId = component.get("v.selectedTab");
        var currentTab = document.getElementById(globalId+'_'+currentTabId);
        $A.util.removeClass(currentTab, 'slds-is-active');
        $A.util.addClass(parentElement, 'slds-is-active');
        component.set("v.selectedTab", parentElement.id.split('_')[1]);
        component.set('v.currentTabName', event.currentTarget.name);
        helper.showTabContent(component, component.get("v.uiSettings"), event.currentTarget.name);
    },

    openResendInvoicePopup: function(component, event, helper){
        helper.openResendInvoicePopup(component, event);
    },

    changeAccParams : function(component, event, helper){
        helper.changeAccParams(component, event);
    },

    getPinDeliveryAddress: function(component, event, helper){
        helper.getPinDeliveryAddress(component, event);
    },

    openAccountRecordPage : function(component, event, helper) {
        helper.getIdAndOpenPage(component);
    }
})