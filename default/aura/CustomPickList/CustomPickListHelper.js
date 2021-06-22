({
    getPickListValues : function(component) {
        var objectName = component.get("v.objectName");
        var fieldName = component.get("v.fieldName");
        var dependentField = component.get("v.dependentField");
        var recordTypeId = component.get("v.recordTypeId");
        if(!recordTypeId) {
            recordTypeId = component.get("v.pageReference").state.recordTypeId;
        }
        var action = component.get("c.getPickListValueList");
        action.setParams({
            objectName : objectName,
            fieldName : fieldName,
            recordTypeId : recordTypeId,
            dependentField : dependentField
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var values = response.getReturnValue();
                this.preparePicklist(component, values);
                component.set('v.itemList', values);
            }
            else{
                console.log('ERROR', response.getError());
            }
        })
        $A.enqueueAction(action);
    },

    preparePicklist : function(component, values) {
        var isDefaultEmpty = component.get("v.isDefaultEmpty");
        var defaultValue = component.get("v.default");
        component.set('v.selectedValue', values[0]);
        if(!isDefaultEmpty) {
            if(defaultValue){
                var index = values.indexOf(defaultValue);
                if (index !== -1) {
                    values.splice(index, 1);
                    values.unshift(defaultValue);
                    component.set('v.selectedValue', defaultValue);
                } 
            }
        } else {
            component.set('v.selectedValue', '');
        }
    }
})
