({
    showToast: function(message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error!",
            "message": message
        });
        toastEvent.fire();
    }
})