({
    getData: function(component, event) {
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            var params = this.prepareGFNParameters(event, gfnParams, component);
            this.callServerMethod(
                component,
                "c.getPriceRules",
                params,
                (response) => {
                    var returnValue = response.getReturnValue();
                    component.set("v.errorMessage", "No active Price Rules")
                    if(returnValue){
                        if(returnValue.PriceRules){
                            var priceRules = JSON.parse(returnValue.PriceRules);
                            priceRules = this.filterRules(priceRules);
                            var itemList = this.prepareData(priceRules);
                            component.set('v.itemList', itemList);
                        }
                        if(returnValue.Customerpricerulessearch){
                            component.set('v.landingPageLink', returnValue.Customerpricerulessearch);
                        }
                    }
                },
                (response) => {
                    this.handleErrorState(response, "Price Rules", component);
                }
            );
        } else {
            component.set('v.loaded', true);
            component.set('v.errorMessage', 'Incorrect GFN Parameters');
        }
    },

    filterRules: function(rules){
        var result = [];
        if(Array.isArray(rules) && rules.length){
            var today = new Date();
            for(var i = 0; i< rules.length; i=i+1){
                if((new Date(rules[i].DateTerminated) > today) && !rules[i].PriceRuleDescription.includes("Retail")){
                    result.push(rules[i]);
                }
            }
        }
        return result;
    },

    prepareData : function(data){
        var itemList = [];
        if(Array.isArray(data) && data.length){
            for(var i = 0; i<data.length; i=i+1){
                var row = [];
                var value = this.getValues(data[i]);
                var sites = this.getSite(data[i]);
                var products = this.getProducts(data[i]);
                row.push({Value: data[i].PriceRuleDescription});
                row.push({Value: this.formatDate(data[i].DateEffective, true)});
                row.push({Value: value});
                row.push({Value: sites});
                row.push({Value: products.productGroup});
                row.push({Value: products.products});
                row.push({Value: data[i].ReferencePrice});
                row.push({Value: data[i].PriceRuleBasis});
                itemList.push(row);
            }
        }
        return itemList;
    },

    getValues: function(priceRule){
        var value;
        if(priceRule.PriceRuleTiers && Array.isArray(priceRule.PriceRuleTiers) && priceRule.PriceRuleTiers.length){
            var tiers = priceRule.PriceRuleTiers;
            var values = [];
            for(var j = 0; j< tiers.length; j=j+1){
                if(tiers[j].Value || tiers[j].Value == 0){
                    values.push(tiers[j].Value);
                }
            }
            value = values.join(', ');
        }
        return value
    },

    getProducts: function(priceRule){
        var productsInfo;
        if(priceRule.PriceRuleProducts && Array.isArray(priceRule.PriceRuleProducts) && priceRule.PriceRuleProducts.length){
            var priceRuleProducts = priceRule.PriceRuleProducts;
            var productList = [];
            var productGroupList = [];
            for(var j = 0; j< priceRuleProducts.length; j=j+1){
                if(priceRuleProducts[j].Product && !productList.includes(priceRuleProducts[j].Product)){
                    productList.push(priceRuleProducts[j].Product);
                }
                if(priceRuleProducts[j].ProductGroup && !productGroupList.includes(priceRuleProducts[j].ProductGroup)){
                    productGroupList.push(priceRuleProducts[j].ProductGroup);
                }
            }
            productsInfo = {
                products: productList.join(', '),
                productGroup: productGroupList.join(', ')
            }
        }
        return productsInfo;
    },

    getSite: function(priceRule){
        var sites;
        if(priceRule.PriceRuleLocations && Array.isArray(priceRule.PriceRuleLocations) && priceRule.PriceRuleLocations.length){
            var location = priceRule.PriceRuleLocations;
            var shortNameList = [];
            for(var j = 0; j< location.length; j=j+1){
                if(location[j].SiteShortName){
                    shortNameList.push(location[j].SiteShortName);
                }
            }
            sites = shortNameList.join(', ');
        }
        return sites;        
    }
})