({

    getProductList : function(component, event){
        var gfnParameters = component.get("v.gfnParams");
        if(gfnParameters){
            gfnParameters = gfnParameters.split(',');
            var params = this.prepareGFNParameters(event, gfnParameters, component);
            this.callServerMethod(
                component,
                "c.getAccountUnbilledProductsGfn",
                params,
                (response)=>{
                    var productList = response.getReturnValue();
                    if(productList && productList.UnbilledProducts){
                        productList = JSON.parse(productList.UnbilledProducts);
                        productList.sort(function(a,b){
                            if(a.Product<b.Product){return -1;}
                            if(a.Product>b.Product){return 1;}
                            return 0;
                        });
                        component.set('v.productList', productList);
                    }
                },
                (response)=>{
                    this.handleErrorState(response, "Unbilled Transactions", component)
                }
            );
        } else {
            component.set('v.loaded', true);
            component.set('v.errorMessage', "Incorrect GFN parmeters");
        }
    },

    getTransactions : function(component, event){
        var gfnParameters = component.get("v.gfnParams");
        if(gfnParameters){
            gfnParameters = gfnParameters.split(',');
            var params = this.prepareGFNParameters(event, gfnParameters, component);
            params.recordType = component.get("v.recordType");

            this.callServerMethod(
                component,
                "c.getAccountUnbilledTransactionsGfn",
                params,
                (response)=>{
                    component.set("v.errorMessage", "No Unbilled Transactions");
                    var transactions = response.getReturnValue();
                    if(transactions && transactions.UnbilledTransactions){
                        var allTransactions = JSON.parse(transactions.UnbilledTransactions);
                        if(Array.isArray(allTransactions) && allTransactions.length){
                            allTransactions.sort((a, b)=>{
                                var a_date = new Date(a.SalesDateTime);
                                var b_date = new Date(b.SalesDateTime);
                                if(a_date>b_date){
                                    return -1;
                                }
                                if(a_date<b_date){
                                    return 1;
                                }
                                return 0;
                            });
                            for(var i = 0; i<allTransactions.length; i=i+1){
                                allTransactions[i].SalesDateTime = this.formatDate(allTransactions[i].SalesDateTime);
                                if(!(''+allTransactions[i].Quantity).includes('.')){
                                    allTransactions[i].Quantity =  `${allTransactions[i].Quantity}.00`;
                                }
                                if(!(''+allTransactions[i].AmountGross).includes('.')){
                                    allTransactions[i].AmountGross =  `${allTransactions[i].AmountGross}.00`;
                                }
                                if(!(''+allTransactions[i].AmountNet).includes('.')){
                                    allTransactions[i].AmountNet =  `${allTransactions[i].AmountNet}.00`;
                                }
                            }
                        }
                        var transactionsToShow = allTransactions.slice(0, 10);
                        component.set('v.itemList', transactionsToShow);
                        component.set("v.allTransactions", allTransactions);
                        component.set('v.searchResults', allTransactions);
                        component.set('v.landingPageLink', transactions.CustomerTransactionsSearchLandingPage);
                    }
                },
                (response)=>{
                    this.handleErrorState(response, "Unbilled Transactions", component)
                }
            );
        } else {
            component.set('v.loaded', true);
            component.set('v.errorMessage', "Incorrect GFN parmeters");
        }
    },

    isSearchResult: function(transaction, dateFromField, dateToField, cardNumber, product){
        var date = this.getDateFromString(transaction.SalesDateTime);
        var dateFrom = new Date(dateFromField);
        dateFrom.setHours(0);
        var dateTo = new Date(dateToField);
        dateTo.setHours(24);
        return  (!this.isValidDate(dateFrom) || !dateFromField || date>=dateFrom) && 
                (!this.isValidDate(dateTo) || !dateToField || date<=dateTo) && 
                (!cardNumber || (cardNumber==="") || transaction.Card.search(cardNumber)!= -1) &&
                (!product || (product==="") || transaction.Product.toLowerCase().search(product.toLowerCase())!= -1);
    },

    isValidDate: function(d) {
        return d instanceof Date && !isNaN(d);
    },

    getDateFromString: function(dateString){
        var dateParams = dateString.split('/');
        var day = dateParams[0];
        var month = dateParams[1]-1;
        var yearAndTime = dateParams[2].split(' ');
        var year = yearAndTime[0];
        var time = yearAndTime[1].split(':');
        var hours = time[0];
        var minutes = time[1];
        return new Date(year, month, day, hours, minutes, 0, 0);
    }

})