({
    doInit : function(component, event, helper) {
        // var tableHead = ['Frequency', 'Distribution Method', 'Notification e-mail'];
        // component.set('v.tableHead', tableHead);
        helper.getData(component, event);
    }
})