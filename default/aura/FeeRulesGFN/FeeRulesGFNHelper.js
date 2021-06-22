({
    getData : function(component, event) {
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            var params = this.prepareGFNParameters(event, gfnParams, component);
            this.callServerMethod(
                component,
                "c.getFeeRules",
                params,
                (response) => {
                    var returnValue = response.getReturnValue();
                    component.set("v.errorMessage", "No active Fee Rules");
                    if(returnValue){
                        if(returnValue.FeeRules){
                            var feeRules = JSON.parse(returnValue.FeeRules);
                            var itemList = this.prepareData(feeRules);
                            component.set('v.itemList', itemList);
                        }
                        if(returnValue.Customerfeerulesearch){
                            component.set('v.landingPageLink', returnValue.Customerfeerulesearch);
                        }
                    }
                },
                (response) => {
                    this.handleErrorState(response, 'FeeRules', component);
                }
            )
        } else {
            component.set('v.loaded', true);
            component.set('v.errorMessage', 'Incorrect GFN Parameters');
        }
    },

    prepareData : function(data){
        var itemList = [];
        if(Array.isArray(data) && data.length){
            for(var i = 0; i<data.length; i=i+1){
                var row = [];
                if(data[i].FeeRuleDescription){
                    row.push({Value: data[i].FeeRuleDescription});
                }
                row.push({Value: this.formatDate(data[i].DateEffective, true)});
                if(data[i].FeeType == 'Transaction Fee Non-Home-Site' || data[i].FeeType == 'Simple Fee') {
                    row.push({Value: data[i].FeeType});
                }
                else {
                    row.push({Value: ''});
                }
                if(data[i].FeeType == 'Simple Fee') {
                    row.push({Value: data[i].FrequencyType});
                }
                else {
                    row.push({Value: ''});
                }
                itemList.push(row);
            }
            itemList.sort(this.compareRules);
        }
        return itemList;
    },

    filterRules: function(rules){
        var result = [];
        if(Array.isArray(rules) && rules.length){
            var today = new Date();
            for(var i = 0; i< rules.length; i=i+1){
                if(rules[i].Status === 'Active' || rules[i].DateEffective > today){
                    result.push(rules[i]);
                }
            }
        }
        return result;
    },

    compareRules: function(a, b){
        if(a[0] && b[0]){
            if(a[0].Value<b[0].Value){
                return -1;
            }
            if(a[0].Value>b[0].Value){
                return 1;
            }
        }
        return 0;
    }
})