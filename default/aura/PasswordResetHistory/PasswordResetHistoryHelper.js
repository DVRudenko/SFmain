({
    getHistory : function(component) {
        let gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            let params = {
                customerNumber : gfnParams[1]
            };
            this.callServerMethod(
                component,
                "c.getResetPasswordHistory",
                params,
                (response) => {
                   this.handleSuccessResponse(response, component); 
                },
                (response) => {
                    this.handleErrorState(response, 'PasswordResetHistory', component);
                }
            );
        } else {
            component.set('v.loaded', true);
            component.set('v.errorMessage', 'Incorrect GFN Parameters');
        }
    },

    handleSuccessResponse : function(response, component) {
        let returnValue = response.getReturnValue();
        let rows = returnValue.split('\n');
        let itemList = [];
        console.log('HISTORY===', returnValue);
        for(let i = 0; i < rows.length; i++) {
            let dataList = rows[i].split(',');
            let row = [];
            for(let j = 0; j < dataList.length; j++) {
                if(j == 0) {
                    dataList[j] = this.formatDate(Number(dataList[j]), false, 0);
                }
                row.push({
                    Value : dataList[j]
                });
            }
            itemList.push(row);
        }
        component.set('v.itemList', itemList);
    },

})
