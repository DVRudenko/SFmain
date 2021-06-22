({
    getGfnParameters : function(component, recordId, objectName) {
        var action = component.get("c.init");
        action.setParams({
            "currentObjectId" : recordId,
            "objectType": objectName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var gfnParams;
                if(!result.colCoId || !result.customerGfnNumber){
                    this.showToast("ColCo or GFN Number is empty");
                } else {
                    gfnParams = result.colCoId.toString().split(".")[0]+','+result.customerGfnNumber;
                }
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(tab) {
                    var focusedTabId = tab.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "GFN "+result.customerGfnNumber
                    });
                }).catch(function(error) {
                    console.log(error);
                });
                component.set('v.recordType', result.recordType);
                component.set("v.gfnParams", gfnParams);
                this.handleUISettings(component, result);

            }
            
            else {
                this.showToast('Unexpected error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function(message){
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": message
            });
            toastEvent.fire();   
        } catch (error) {
            alert(message);
        }
    },

    openResendInvoicePopup : function(component, event){
        var isResendInvoiceOpened = event.getParam("isResendInvoicePopupOpened");
        var popupType = event.getParam("popupType");
        component.set('v.popupType', popupType);
        if(isResendInvoiceOpened){
            if(popupType == 'Resend Invoice'){
                var caseParameters = {
                    Topic: 'Invoices & Payments', 
                    Subtopic: 'Invoice resend',
                    Subject: ''
                };
                component.set('v.popupCaseParameters', caseParameters);
            } else if(popupType == 'Resend PIN'){
                var caseParameters = {
                    Topic: 'My Card(s)', 
                    Subtopic: 'Card Other Questions',
                    Subject: 'Resend PIN for FLEETCOR customer'
                };
                component.set('v.popupCaseParameters', caseParameters);                
            }
            var docNumberList = event.getParam("docNumberList");
            var cards = event.getParam("cards");
            component.set('v.docNumberList', docNumberList);
            component.set('v.cards', cards);
        }
        component.set('v.isResendInvoice', isResendInvoiceOpened);
    },

    changeAccParams : function(component, event){
        var gfnParams = component.get("v.gfnParams").split(",");
        var accParams = event.getParam('accParams');
        var companyName = event.getParam('companyName');
        component.set('v.accParams', accParams);
        component.set('v.companyName', companyName);
        component.set("v.baseInfo", `${gfnParams[1]} - ${companyName}`);
    },

    getPinDeliveryAddress: function(component, event){
        var address = event.getParam("address");
        component.set('v.pinDeliveryAddress', address);
    },

    getIdAndOpenPage : function(component) {
        var accountId = component.get("v.accountId");
        if( !accountId ) {
            let lineOfBusiness = component.get("v.recordType");
            if(lineOfBusiness == 'SME') {
                this.getRelatedAccount(component);
            } else {
                this.getRelatedERP(component);
            }
        } else {
            this.openAccountRecordPage(component, accountId);
        }
    },

    openAccountRecordPage : function (component, accountId) {
        var isClassic = component.get("v.isClassic");
        if(isClassic){
            window.open('/' + accountId);
        } else {
            var workspaceAPI = component.find("workspace");
            var recordPageUrl = '/lightning/r/ERP__c/' + accountId + '/view';
            let lineOfBusiness = component.get("v.recordType");
            if(lineOfBusiness == 'SME') {
                recordPageUrl = '/lightning/r/Account/' + accountId + '/view';
            }
            var self = this;
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                workspaceAPI.getTabInfo({
                    tabId: response.parentTabId
                }).then(function(response) {
                    if(response.url.includes(recordPageUrl)){
                        workspaceAPI.focusTab({ tabId : response.tabId });
                    } else {
                        self.openNewSubTab(workspaceAPI, recordPageUrl)
                    }
                }).catch(function(error){
                    self.openNewSubTab(workspaceAPI, recordPageUrl);                
                });
            }).catch(function(error){
                self.openNewSubTab(workspaceAPI, recordPageUrl);
            });
        }
    },

    openNewSubTab : function(workspaceAPI, recordPageUrl) {
        workspaceAPI.openSubtab({
            url: recordPageUrl,
            focus: true
        }).catch(function(error) {
            console.log(error);
        });
    },

    prepareTabList : function(uiSettings, component) {
        let tabList = [];
        for(let i = 0; i < uiSettings.length; i++) {
            if ( this.isTabNotExist(tabList, uiSettings[i].Tab__c) ) {
                tabList.push({
                    Id: '_' + uiSettings[i].Tab__c.split(' ').join('-'),
                    Name: uiSettings[i].Tab__c,
                    Icon : uiSettings[i].Tab_Icon__c
                });
            }
        }
        component.set('v.tabList', tabList);
    },

    isTabNotExist : function(tabList, currentTab) {
        let filtredTabs = tabList.filter((tab)=>{
            return tab.Name == currentTab;
        });
        if(filtredTabs.length > 0) {
            return false;
        }
        return true;
    },


    showTabContent : function(component, uiSettings, currentTabName) {
        let preparedUISettings = this.prepareSettingsToShow(uiSettings, currentTabName, component);
        console.log('SETTINGS', preparedUISettings);
        $A.createComponents(
            preparedUISettings,
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    component.set('v.body', components);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },

    prepareSettingsToShow : function(uiSettings, currentTabName, component) {
        let preparedSettings = [];
        let componentsToShow = uiSettings.filter((setting)=>{
            return setting.Tab__c == currentTabName;
        });
        console.log('recordType===', component.get("v.recordType"));
        for(let i = 0; i < componentsToShow.length; i++) {
            preparedSettings.push(
                [
                    'c:' + componentsToShow[i].Label,
                    {
                        'gfnParams' : component.get("v.gfnParams"),
                        'isClassic' : component.get("v.isClassic"),
                        "tableHead" : componentsToShow[i].Fields__c.split(','),
                        "recordType" : component.get("v.recordType"),
                        "lineOfBusiness" : component.get("v.recordType")
                    }
                ]
            );
        }
        return preparedSettings;
    },

    getUISettingsAndOpenDashboard : function(component) {
        var action = component.get("c.getUISettings");
        console.log('ID===>', component.get("v.recordType"));
        action.setParams({
            lineOfBusiness : component.get("v.recordType")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                this.handleUISettings(component, result);

            }
            else {
                let isClassic = component.get("v.isClassic");
                console.log("Error: " + response.getError()[0].message);
                if (isClassic) {
                    alert('Error during getting UI settings');
                }
                else {
                    this.showToast('Error during getting UI settings');
                }
            }
        })
        $A.enqueueAction(action);
    },

    handleUISettings : function(component, result) {
        component.set('v.uiSettings', result.uiSettings);

        result.uiSettings.sort((a,b)=>{
            if (a.Priority__c > b.Priority__c) {
                return 1;
            } else if (a.Priority__c < b.Priority__c) {
                return -1;
            } else {
                return 0;
            }
        })

        this.prepareTabList(result.uiSettings, component);
        console.log('UI===', result.uiSettings);
        this.showTabContent(component,result.uiSettings, result.uiSettings[0].Tab__c);
    },

    getRelatedERP: function(component) {
        var customerNumber = component.get("v.baseInfo").split(" - ")[0];
        var action = component.get("c.getRelatedERPId");
        action.setParams({
            customerNumber: customerNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let accountId = response.getReturnValue();
                if(accountId){
                    this.openAccountRecordPage(component, accountId);
                } else {
                    this.showToast('Account with GFN number ' + customerNumber + ' does not exist in Salesforce database');
                }
            }
            else {
                this.showToast('Error!');
            }
        })
        $A.enqueueAction(action);
    },

    getRelatedAccount: function(component) {
        var customerNumber = component.get("v.baseInfo").split(" - ")[0];
        var action = component.get("c.getRelatedAccountId");
        action.setParams({
            customerNumber: customerNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let accountId = response.getReturnValue();
                if(accountId){
                    this.openAccountRecordPage(component, accountId);
                } else {
                    this.showToast('Account with GFN number ' + customerNumber + ' does not exist in Salesforce database');
                }
            }
            else {
                this.showToast('Error!');
            }
        })
        $A.enqueueAction(action);
    }
})