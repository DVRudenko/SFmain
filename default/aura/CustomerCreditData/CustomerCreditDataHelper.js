({
    getCreditDataFromGFN : function(component, event) {
        var gfnParameters = component.get("v.gfnParams");
        if(gfnParameters){
            var params = this.prepareGFNParameters(event, gfnParameters.split(','), component);
            this.callServerMethod(
                component,
                "c.getCreditData",
                params,
                (response)=>{
                    var responseValue = response.getReturnValue();
                    component.set("v.errorMesage", "No Credit Data to be displayed");

                    var itemList = this.prepareData(responseValue, component);
                    if(itemList && itemList.length){
                        component.set('v.itemList', itemList);
                    }

                    component.set('v.landingPageLink', responseValue.CustomerCreditDataMaintenance);
                },
                (response)=>{
                    this.handleErrorState(response, 'Payments', component);
                }
            );
        } else {
            component.set('v.loaded', true);
            component.set('v.errorMessage', "Incorrect GFN Credit Data");
        }
    },

    prepareData: function(responseValue, component) {
        let itemList = [];
        let creditData = JSON.parse(responseValue.CreditData);
        for(let i = 0; i < creditData.length; i++) {
            let row = [];
            let creditScoreClassName = ''
            row.push({Value: creditData[i].ExternalCreditManager});
            row.push({Value: creditData[i].ExternalAccountingClerk});
            row.push({Value: creditData[i].CreditSystemCustomerNumber});
            row.push({Value: creditData[i].PaymentIndex});
            if(creditData[i].CreditScore !== 0) {
                creditScoreClassName = 'column-red-color';
            }
            row.push({
                Value: creditData[i].CreditScore, 
                className : creditScoreClassName
            });
            itemList.push(row);
        }
        return itemList;
    }
})
