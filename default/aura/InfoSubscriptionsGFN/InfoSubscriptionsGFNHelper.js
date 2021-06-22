({
    getData : function(component, event){     
        var gfnParameters = component.get("v.gfnParams");
        if(gfnParameters){
            var params = this.prepareGFNParameters(event, gfnParameters.split(','), component);
            this.callServerMethod(
                component,
                "c.getAccountInformationSubscriptionsGfn",
                params,
                (response)=>{
                    var returnValue = response.getReturnValue();
                    component.set("v.errorMesage", "No active Info Subscriptions");
                    // console.log('returnValue', returnValue);
                    component.set('v.landingPageLink', returnValue.MaintainCustomerInfoSubscriptionLandingPage);
                    if(returnValue && returnValue.InfoSubscriptions){
                        var value = JSON.parse(returnValue.InfoSubscriptions);
                        var itemList = this.prepareData(value);
                        if(itemList && itemList.length){
                            component.set('v.itemList', itemList);
                        }
                    }
                },
                (response)=>{
                    this.handleErrorState(response, 'Info Subscriptions', component);
                }
            );
        } else{
            component.set('v.loaded', true);
            component.set("v.errorMessage", "Incorrect GFN Parameters");
        }
    },

    prepareData : function(data){
        var itemList = [];
        if(Array.isArray(data) && data.length){
            for(var i = 0; i<data.length; i=i+1){
                var subsDetails = data[i].InfoSubscriptionDetails;
                var rows = [];
                if(subsDetails && subsDetails.length){
                    for(var j = 0; j<subsDetails.length; j=j+1){
                        var row = [];
                        var emailAddresses = [];
                        row.push({Value: data[i].FrequencyType});
                        row.push({Value: subsDetails[j].DistributionMethod+' - '+subsDetails[j].OutputType});
                        var accountInfo = subsDetails[j].AccountInfoSubscriptionContacts;
                        if(subsDetails[j].DistributionMethod != 'Print' && accountInfo && accountInfo.length){
                            for(var k = 0; k<accountInfo.length; k=k+1){
                                // if(accountInfo[k].isPrimary){
                                emailAddresses.push(accountInfo[k].EMailAddress);
                                // }
                            }
                        }
                        row.push({Value: emailAddresses.join(', ')});
                        if(row.length && row.find(function(element){return element.Value})){
                            rows.push(row);
                        }
                        
                    }
                } else {
                    var row = [];
                    if(data[i].FrequencyType){
                        row.push({Value: data[i].FrequencyType});
                        row.push({Value: null});
                        row.push({Value: null});
                        if(row.length && row.find(function(element){return element.Value})){
                            rows.push(row);
                        }
                    }
                }
                if(rows.length){
                    itemList = itemList.concat(rows);
                }
            }
        }
        return itemList;
    }
})