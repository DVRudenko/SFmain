({
    doInit : function(component, event, helper) {
        // var contactTableHead = ['Title', 'Name', 'Phone', 'Mobile', 'E-mail', 'Contact Type'];
        // component.set("v.contactTableHead", contactTableHead);
        helper.getContacts(component, event);
    },

    getContactData : function(component, event, helper){
        helper.getContacts(component, event, true);
    }
})