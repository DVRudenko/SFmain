({

    getPayments: function(component, event){
        var gfnParameters = component.get("v.gfnParams");
        if(gfnParameters){
            var params = this.prepareGFNParameters(event, gfnParameters.split(','), component);
            this.callServerMethod(
                component,
                "c.getAccountPaymentDetailsGfn",
                params,
                (response)=>{
                    var responseValue = response.getReturnValue();
                    component.set("v.errorMesage", "No Payments to be displayed");
                    var itemList = this.prepareData(responseValue, component);
                    if(itemList && itemList.length){
                        component.set('v.itemList', itemList);
                    }

                    component.set('v.landingPageLink', responseValue.MaintainCustomerPaymentDetailsLandingPage);
                },
                (response)=>{
                    this.handleErrorState(response, 'Payments', component);
                }
            );
        } else {
            component.set('v.loaded', true);
            component.set('v.errorMessage', "Incorrect GFN Parameters");
        }
    },
    
    prepareData : function(data, component){
        let lob = component.get("v.lineOfBusiness");
        var itemList = [];
        var row = [];
        var debtStatus = {Value: data.DebStatus};
        if(data.DebStatus != 'GP Managed'){
            debtStatus.className = 'column-red-color';
        }
        row.push(debtStatus);
        var outstandDebt = this.addSpaces(data.OutstandDebt);
        if(data.OutstandDebtCurrency){
            outstandDebt = outstandDebt + ' ' + data.OutstandDebtCurrency
        }
        row.push({Value: outstandDebt});

        if(lob == 'SME') {
            var exposure = this.addSpaces(data.Exposure);
            if(data.Exposure){
                exposure = exposure + ' ' + data.CreditLimitCurrency;
            }
            row.push({Value: exposure})
        }

        var creditLimit = this.addSpaces(data.CreditLimit);
        if(data.CreditLimitCurrency){
            creditLimit = creditLimit + ' ' + data.CreditLimitCurrency;
        }
        row.push({Value: creditLimit});
        row.push({Value: data.PaymentMethod});
        row.push({Value: data.PaymentTerms});
        var guarantee = this.addSpaces(data.Guarantee);
        if(data.GuarenteeCurrency){
            guarantee  = guarantee + ' ' + data.GuarenteeCurrency
        }
        row.push({Value: guarantee});
        if(row.length && row.find(function(element){return element.Value})){
            itemList.push(row);
        }
        return itemList;
    },

    addSpaces: function(nStr)
    {
        nStr += '';
        var x = nStr.split('.');
        var x1 = x[0];
        var x2 = x.length > 1 ? '.' + x[1] : '';
        var rgx = /(\d+)(\d{3})/;
        while (rgx.test(x1)) {
            x1 = x1.replace(rgx, '$1' + ' ' + '$2');
        }
        return x1 + x2;
    }
})