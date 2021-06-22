({
    redirectAccordingRecordType : function(component) {
        var action = component.get("c.getRecordTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recordTypes = response.getReturnValue();
                var currentRecordType = component.get("v.pageReference").state.recordTypeId;
                if(currentRecordType && !recordTypes[currentRecordType]) {
                    window.open('/lightning/o/Case/new?recordTypeId=' + currentRecordType + '&nooverride=true','_top')
                } else if(currentRecordType) {
                    component.set('v.recordTypeId', currentRecordType);
                    component.set('v.recordTypeName', recordTypes[currentRecordType]);
                    this.getLayoutData(component, currentRecordType);
                    // component.set('v.display', true);
                }
                if(!currentRecordType) {
                    var action = component.get("c.getAvailableRecordType");
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            currentRecordType = response.getReturnValue();
                            component.set('v.recordTypeId', currentRecordType);
                            if(currentRecordType && !recordTypes[currentRecordType]) {
                                window.open('/lightning/o/Case/new?recordTypeId=' + currentRecordType + '&nooverride=true','_top');
                            } else {
                                component.set('v.recordTypeName', recordTypes[currentRecordType]);
                                this.getLayoutData(component, currentRecordType);
                                // component.set('v.display', true);
                            }
                        }
                        else{
                            console.log('ERROR',response.getError() );
                        }
                    })
                    $A.enqueueAction(action);
                }
            }
            else {
                console.log('ERROR', response.getError());
            }
        })
        $A.enqueueAction(action);
    },

    navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId,
            "isredirect": true
        });
        navEvt.fire();
    },

    validateFields : function(component) {
        var notValidatedFields = [];
        var fields = component.find('caseField');
        for(let i = 0; i < fields.length; i++) {
            var required = fields[i].get("v.required");
            var fieldValue = fields[i].get("v.value");
            if(required && !fieldValue) {
                var fieldName = fields[i].get("v.fieldName");
                fieldName = fieldName.replace('__c', '');
                fieldName = fieldName.replace('_', ' ');
                notValidatedFields.push(fieldName);
            }
        }
        return notValidatedFields;
    },

    showToast : function(message, title, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    uploadAttachment : function(component, recordId, files) {
        // var files = component.get("v.filesToUpload");
        var self = this;
        for (let i = 0; i < files.length; i++) {
            let reader = new FileReader();
            reader.readAsDataURL(files[i]);
            reader.onload = function () {
                var encodedFile = reader.result;
                if(encodedFile){
                    var dataStart = encodedFile.indexOf('base64,') + 'base64,'.length;
                    encodedFile = encodedFile.substring(dataStart);
                }
                var action = component.get("c.attachFileToCase");
                action.setParams({
                    encodedContentsString : encodedFile,
                    fileName : files[i].name,
                    recordId : recordId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('ATTACHMENT SUCCESS');
                        if(i == (files.length-1)) {
                            component.set('v.loading', false);
                            self.navigateTo(component, recordId);
                        }
                    }
                    else {
                        console.log('ATTACHMENT ERROR === ', response.getError());
                        var attachmentsToReload = component.get("v.attachmentsToReload");
                        attachmentsToReload.push(files[i]);
                        component.set('v.attachmentsToReload', attachmentsToReload);
                        self.showToast('Attachment is not created: ' + files[i].name, '', 'Error');
                        component.set('v.attachmentError', true);
                    }
                    if(i == (files.length-1)) {
                        var attachments = component.get("v.attachmentsToReload");
                        component.set('v.loading', false);
                        component.set('v.filesToUpload', attachments);
                        // self.navigateTo(component, recordId);
                    }
                })
                $A.enqueueAction(action);
            };
        }
        if(!files || files.length == 0){
            component.set('v.loading', false);
            self.navigateTo(component, recordId);
        }
    },

    closeTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    getLayoutData : function(component, recordType) {
        var recordTypeName = component.get("v.recordTypeName");
        var layoutName = 'Case-Support Case Layout'
        if(recordTypeName == 'Support CCS') {
            layoutName = 'Case-Support Case Layout';
        } else if(recordTypeName == 'Support') {
            layoutName = 'Case-Shell Support Case Layout';
        }
        var action = component.get("c.getPageLayoutData");
        action.setParams({
            layoutName : layoutName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var layoutData = response.getReturnValue();
                layoutData = this.prepareLayoutData(JSON.parse(layoutData));
                console.log('layoutData', layoutData);
                component.set('v.layoutData', layoutData);
                component.set('v.display', true);
            }
            else{
                console.log('LAYOUT ERROR', response.getError());
            }
        })
        $A.enqueueAction(action);
    },

    prepareLayoutData : function(layoutData) {
        var hiddenItems = ['CreatedDate', 'ClosedDate', 'CreatedById', 'Processing_time__c', 'Handling_Time__c', 'LastModifiedById', 'ContactPhone', 'ContactEmail'];
        var itemsWithLabels = ['AccountId', 'ContactId', 'SuppliedEmail', 'SuppliedName', 'SuppliedCompany', 'SuppliedPhone', 'RecordTypeId', 'OwnerId', 'ParentId'];
        for(let i = 0; i < layoutData.length; i++) {
            var columns = layoutData[i].layoutColumns;
            for(let j = 0; j < columns.length; j++) {
                var items = columns[j].layoutItems;
                if(items) {
                    for(let k = 0; k < items.length; k++) {
                        if(hiddenItems.includes(items[k].field)) {
                            items[k].Hidden = true;
                        }
                        if(itemsWithLabels.includes(items[k].field)) {
                            items[k].HasCustomLabel = true;
                            items[k].CustomLabel = this.getLabel(items[k].field);
                        }
                    }
                }
            }
        }
        return layoutData;
    },

    getLabel : function(fieldName) {
        var fieldLabelMapping = {
            'AccountId' : 'Account Name', 
            'ContactId' : 'Contact Name', 
            'SuppliedEmail' : 'Web Email', 
            'SuppliedName' : 'Web Name', 
            'SuppliedCompany' : 'Web Company', 
            'SuppliedPhone' : 'Web Phone', 
            'RecordTypeId' : 'Record Type', 
            'OwnerId' : 'Owner', 
            'ParentId' : 'Parent Case'
        }
        return fieldLabelMapping[fieldName];
    },

    getParentAccount: function(component) {
        var ws = component.get("v.pageReference").state.ws
        if(ws){
            var dec = decodeURI(ws);
            var res = dec.split("/");     
            for(var i = 0; i<res.length; i++){     
                if(res[i] == "Account" && res.length > i+1){
                    var accId = res[i+1];
                    component.set("v.parentAccountId", accId);
                }
                
                if(res[i] == "ERP__c" && res.length > i+1){
                    var erpId = res[i+1];
                    component.set("v.parentErpId", erpId);
                    var action = component.get("c.getParentAccountForERP");
                    action.setParams({
                        erpId : erpId
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var accId = response.getReturnValue();
                            console.log('**MT**', accId);
                            component.set("v.parentAccountId", accId);
                        }
                        else{
                            console.log('ERROR', response.getError());
                        }
                    });
                    $A.enqueueAction(action);
                }
            }            
        }
    }
    
})