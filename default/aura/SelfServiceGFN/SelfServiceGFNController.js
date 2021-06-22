({
    doInit : function(component, event, helper) {
        component.set("v.loaded", false);
        helper.getData(component, event);
    },

    getAccounts : function(component, event, helper){
        helper.getSelfServiceData(component, event);
    },

    resetPasswords: function(component, event, helper){
        var allCheckboxes = component.find("checkbox");
        var userNameList = [];
        if(Array.isArray(allCheckboxes)){
            for (var i = 0; i < allCheckboxes.length; i++) {
                if (allCheckboxes[i].get("v.checked")) {
                    userNameList.push(allCheckboxes[i].get("v.name"));
                }
            }
        } else {
            if(allCheckboxes){
                if (allCheckboxes.get("v.checked")) {
                    userNameList.push(allCheckboxes.get("v.name"));
                }  
            }
        }
        helper.resetPassword(component, userNameList);
    }
})