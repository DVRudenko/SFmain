({

    getData : function(component, event){
        var gfnParams = component.get("v.gfnParams");
        var params;
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            params = this.prepareGFNParameters(event, gfnParams, component);
            params.recordType = component.get("v.recordType");
            this.setCurrency(component, params.colCoID);
            this.callServerMethod(
                component,
                "c.getBillingDocuments",
                params,
                (response) => {
                    var returnValue = response.getReturnValue();
                    if(returnValue){
                        var currency = component.get("v.currency");
                        if(returnValue.BillingDocuments){                            
                            var billingDocuments = this.prepareData(JSON.parse(returnValue.BillingDocuments), returnValue.BaseURL, currency);
                            if(! billingDocuments || !billingDocuments.length){
                                component.set('v.errorMessage', "No Billing Documents to be displayed");
                            }
                            component.set('v.itemList', billingDocuments);
                        } else {
                            component.set('v.errorMessage', "No Billing Documents to be displayed");
                        }
                        if(returnValue.Listcustomersummaryinvoice){
                            component.set('v.landingPageLink', returnValue.Listcustomersummaryinvoice);
                        }
                    }
                },
                (response) => {
                    this.handleErrorState(response, 'Billing documents', component);
                }
            )
        } else {
            component.set('v.loaded', true);
            component.set("v.errorMessage", "Incorrect GFN Parameters");
        }
    },
    
    prepareData : function(billingDocuments, baseUrl, currency){
        if(Array.isArray(billingDocuments) && billingDocuments.length) {
            billingDocuments.sort((a, b)=>{
                var aDate = new Date(a.DocumentDate);
                var bDate = new Date(b.DocumentDate);
                if(aDate < bDate){
                    return 1;
                } else if(aDate > bDate){
                    return -1;
                }
                return 0;
            });
            for(var i=0; i<billingDocuments.length; i=i+1) {
                billingDocuments[i].Checked = false;
                billingDocuments[i].InvoiceURL = baseUrl+billingDocuments[i].InvoicePdfLink;
                billingDocuments[i].PaymentDueDate = this.formatDate(billingDocuments[i].PaymentDueDate, true);
                billingDocuments[i].DocumentDate = this.formatDate(billingDocuments[i].DocumentDate, true);
                this.setTotalGross(billingDocuments[i]);
                this.setAllocatedAmmount(billingDocuments[i], billingDocuments);
            }
            billingDocuments = billingDocuments.slice(0, 24);
            return billingDocuments;
        }
    },


    selectAll: function(component, event, helper){
        var allCheckboxes = component.find("checkbox");
        if(allCheckboxes){
            if(Array.isArray(allCheckboxes) && allCheckboxes.length){
                for(var i = 0; i < allCheckboxes.length; i=i+1){
                    allCheckboxes[i].set("v.checked", true);
                }
            } else{
                allCheckboxes.set("v.checked", true);
            }
        }
    },

    unselectAll: function(component, event, helper){
        var allCheckboxes = component.find("checkbox");
        if(allCheckboxes){
            if(Array.isArray(allCheckboxes) && allCheckboxes.length){
                for(var i = 0; i < allCheckboxes.length; i=i+1){
                    allCheckboxes[i].set("v.checked", false);
                }
            } else{
                allCheckboxes.set("v.checked", false);
            }
        }
    },

    openResendInvoicePopup: function(component, event){
        var allCheckboxes = component.find("checkbox");
        var docNumberList = [];
        if(Array.isArray(allCheckboxes) && allCheckboxes.length){
            for (var i = 0; i < allCheckboxes.length; i++) {
                if(allCheckboxes[i].get("v.checked")){
                    docNumberList.push(allCheckboxes[i].get("v.name"));
                }
            }
        } else {
            if(allCheckboxes && allCheckboxes.get("v.checked")){
                docNumberList.push(allCheckboxes.get("v.name"))
            }
        }
        var compEvent = component.getEvent("ResendInvoiceButtonEvent");
        compEvent.setParams({
            "isResendInvoicePopupOpened":true,
            "docNumberList": docNumberList,
            "popupType": "Resend Invoice"
        });
        compEvent.fire();
    },

    openDocument: function(component, event){
        var docNumber = event.target.name;
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            this.callServerMethod(
                component,
                "c.getDocumentLink",
                {
                    docNumber:docNumber,
                    colCoId: gfnParams[0],
                    customerNumber: gfnParams[1],
                    lineOfBusiness : component.get("v.lineOfBusiness")
                },
                (response)=>{
                    var link = response.getReturnValue();
                    if(link){
                        window.open( link, "_blank"); 
                    } else {
                        this.showInfoToast("Document does not exist.", "Error", "Error", true);
                    }
                    component.set('v.loaded', true);
                },
                (response)=>{
                    console.log('Error', response.getError());
                    this.showInfoToast("Document does not exist.", "Error", "Error", true);
                    component.set('v.loaded', true);
                }
            )
        }
    },

    setCurrency: function(component, colCoId){
        var currencyMapping = {
        '1':' EUR',
        '2':' EUR',
        '3':' EUR',
        '4':' EUR',
        '5':' EUR',
        '6':' HUF',
        '7':' PLN',
        '79':' EUR',
        '80':' CHF',
        '81':' CZK',
        '82':' EUR',
        };
        component.set('v.currency', currencyMapping[colCoId]);
    },

    setTotalGross: function(billingDocument) {
    if(billingDocument && billingDocument.TotalGross) {
        if(!(''+billingDocument.TotalGross).includes('.')) {
            billingDocument.TotalGross = `${billingDocument.TotalGross}.00 ${billingDocument.GFNCurrency}`;
        } else {
            billingDocument.TotalGross = `${billingDocument.TotalGross} ${billingDocument.GFNCurrency}`;
        }
    }
    },

     setAllocatedAmmount: function(billingDocument, documentList) {
        if(billingDocument.AmountAllocated != 0){
            if(billingDocument && billingDocument.AmountAllocated ) {
                if(!(''+billingDocument.AmountAllocated).includes('.')) {
                    billingDocument.AmountAllocated = `${billingDocument.AmountAllocated}.00 ${billingDocument.GFNCurrency}`;
                } else {
                    billingDocument.AmountAllocated = `${billingDocument.AmountAllocated} ${billingDocument.GFNCurrency}`;
                }
            }
        } else {
/*            if(billingDocument.BillingOrSummary == 'SBD') {
                billingDocument.AmountAllocated = billingDocument.TotalGross;
                } else {*/
                var invoicesWithoutSummary = documentList.filter((document)=>{
                    return (document.BillingOrSummary) == 'SBD' && (document.DocumentID == billingDocument.SummaryBillingDocumentID);
                });
                if(!(invoicesWithoutSummary && invoicesWithoutSummary.length && invoicesWithoutSummary.length > 0)){
                    billingDocument.AmountAllocated = `0.00 ${billingDocument.GFNCurrency}`;
                } else{
                    billingDocument.AmountAllocated = '';
                }
//            }
        }
     }
})