({
    getData : function(component) {
        var gfnParameters = component.get("v.gfnParams");
        if(gfnParameters){
            gfnParameters = gfnParameters.split(',');
            var params = this.prepareGFNParameters(event, gfnParameters, component);
            this.callServerMethod(
                component,
                "c.getHomeSitesGFN",
                params,
                (response)=>{
                    var returnValue = response.getReturnValue();
                    var value = [];
                    component.set("v.errorMessage", "No active Home Station")
                    if(returnValue && returnValue.HomeSites){
                        value = JSON.parse(returnValue.HomeSites);
                    }
                    if(returnValue && returnValue.Maintainhomesite){
                        component.set('v.landingPageLink', returnValue.Maintainhomesite);
                    }
                    var itemList = this.prepareData(value);
                    component.set('v.itemList', itemList);
                    if(value[0]){
                        var location = {
                            'Latitude' : value[0].Latitude,
                            'Longitude' : value[0].Longitude,
                        }
                        component.set('v.location', {location:location});
                    }
                },
                (response)=>{
                    this.handleErrorState(response, "Home Sites", component)
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
                row.push({Value: data[i].FullName});
                row.push({Value: data[i].AddressLines});
                row.push({Value: data[i].SiteCode});
                itemList.push(row);
            }
        }
        return itemList;
    }
})