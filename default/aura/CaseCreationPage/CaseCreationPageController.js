({
    doInit : function(component, event, helper) {
        helper.redirectAccordingRecordType(component);
        helper.getParentAccount(component);
        // console.log('**MT**' + ' getParentAccount:'+component.get("v.parentAccountId"));
    },

    createNewCase : function(component, event, helper) {
        var isValid = helper.validateFields(component);
        if(isValid) {
            var caseRecord = component.get("v.caseRecord");
            var tempRec = component.find("recordLoader");
            tempRec.saveRecord($A.getCallback(function(result) {
                var resultsToast = $A.get("e.force:showToast");
                if (result.state === "SUCCESS") {
                    var recordId = result.recordId;
                    helper.uploadAttachment(component, recordId);
                    resultsToast.setParams({
                        "title": "Saved",
                        "message": "The record was saved.",
                        type: 'success'
                    });
                    resultsToast.fire();
                } else if (result.state === "ERROR") {
                    console.log('Error: ' + JSON.stringify(result.error));
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "There was an error saving the record: " + JSON.stringify(result.error)
                    });
                    resultsToast.fire();
                } else {
                    console.log('Unknown problem, state: ' + result.state + ', error: ' + JSON.stringify(result.error));
                }
            }));
        } else {
            helper.showToast('Error')
        }
    },

    handleTopicChange : function(component, event, helper) {
        var value = event.getParam("value");
        console.log('value===', value);
        component.set("v.subtopicDisabled", !(value && value != ''));
    },

    handleFilesChange: function(component, event, helper) {
        var filesToUpload = component.get("v.filesToUpload");
        var files = event.getSource().get("v.files");
        if (files.length > 0) {
            filesToUpload.push(files[0]);
            if(files[0].size > 3200000){
                helper.showToast('Attachment(s) too large! Please remove attachment(s)!', '', 'Error');
            }
        }
        component.set('v.filesToUpload', filesToUpload);
    },

    closePage : function(component, event, helper) {
        helper.closeTab(component);
    },

    removeFile : function(component, event, helper) {
        var filesToUpload = component.get("v.filesToUpload");
        var currentFileName = event.currentTarget.name;
        filesToUpload.splice(parseInt(currentFileName), 1);
        component.set('v.filesToUpload', filesToUpload);
    },

    handleSuccess : function(component, event, helper) {
        helper.showToast('Case was created', '', "success");
        var successResponse = event.getParams().response;
        component.set('v.newCaseId', successResponse.id);
        var files = component.get("v.filesToUpload");
        helper.uploadAttachment(component, successResponse.id, files);
        // helper.save(component, successResponse.id);
    },

    handleError : function(component, event, helper) {
        var errorResponse = event.getParams().error;
        helper.showToast(errorResponse.message, '', 'Error');
    },

    handleClick : function(component, event, helper) {
        var fieldsWithError = helper.validateFields(component);
        if(!(fieldsWithError.length == 0)) {
            helper.showToast('Review the errors on this page. These required fields must be completed: ' + fieldsWithError.join(', '), '', 'Error');
        } else {
            component.set('v.loading', true);
        }
    },

    uploadErrorAttachments : function(component, event, helper) {
        var files = component.get("v.filesToUpload");
        var caseId = component.get("v.newCaseId");
        helper.uploadAttachment(component, caseId, files)
    },

    goToCasePage : function(component, event, helper) {
        var recordId = component.get("v.newCaseId");
        helper.navigateTo(component, recordId);
    }
})