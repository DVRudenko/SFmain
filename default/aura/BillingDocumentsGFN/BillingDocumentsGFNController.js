({
    doInit : function(component, event, helper) {
        // var tableHead = ['Document No', 'Document Type', 'Date', 'Total Gross', 'Allocated Amount', 'Payment Due', 'Delco'];
        // component.set('v.tableHead', tableHead);
        helper.getData(component);
    },

    handleClickCheckbox: function(component, event, helper){
        component.set('v.isIndeterminate', false);
        var isChecked = event.currentTarget.checked;
        if(isChecked){
            helper.selectAll(component);
            component.set('v.hasSelected', true);
        }
        else{
            helper.unselectAll(component);
            component.set('v.hasSelected', false);
        }
        component.set('v.isSelectAll', isChecked);
    },

    handleSimpleCheckboxClick: function(component){
        var allChecked = []
        var allCheckboxes = component.find("checkbox");
        if(allCheckboxes){
            if(!(Array.isArray(allCheckboxes) && allCheckboxes.length)){
                allCheckboxes = [allCheckboxes];
            }
            for(var i = 0; i < allCheckboxes.length; i=i+1){
                if(allCheckboxes[i].get("v.checked")){
                    allChecked.push(allCheckboxes[i]);
                }
            }
        }
        if(allChecked.length === 0){
            component.set('v.isIndeterminate', false);
            component.set("v.isSelectAll", false);
            component.set('v.hasSelected', false);
        } else if (allChecked.length === allCheckboxes.length){
            component.set('v.isIndeterminate', false);
            component.set("v.isSelectAll", true);
            component.set('v.hasSelected', true);
        } else{
            component.set('v.isIndeterminate', true);
            component.set('v.hasSelected', true);
        }
    },

    handleResendButton : function(component, event, helper){
        helper.openResendInvoicePopup(component, event);
    },

    openDocument : function(component, event, helper) {
        component.set('v.loaded', false);
        helper.openDocument(component, event);
    }
})