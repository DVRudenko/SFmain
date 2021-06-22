({
    doInit : function(component, event, helper){
        component.set('v.caseLoaded', false);
        component.set('v.templateLoaded', false);
        component.set('v.emailContent', {
            from:'',
            to: '',
            subject:'',
            body:'',
            invoices:'',
            cc: ''
        });
        helper.getCaseList(component);
    },

    closeModel : function(component, event, helper) {
        var compEvent = component.getEvent("ResendInvoiceButtonEvent");
        compEvent.setParams({"isResendInvoicePopupOpened":false});
        compEvent.fire();
    },

    sendEmail: function(component, event, helper){
        component.set('v.loaded', false);
        helper.sendEmail(component);
    },

    updateCase: function(component, event, helper){
        var isNewCase = component.get("v.isNewCase");
        var type = component.get("v.type");
        if(isNewCase){
            var selectedCase = component.get("v.selectedCase");
            component.set('v.backupCase', selectedCase);
            var emailList = component.get("v.queueEmailList");
            var emailContent = component.get("v.emailContent");
            if(type == 'Resend Invoice'){
                var emailContent = component.get("v.emailContent");
                emailContent.from = emailList[0];
                if(selectedCase){
                    emailContent.subject = emailContent.subject.replace(selectedCase.CaseNumber, '(New Case)');
                }
                component.set('v.emailContent', emailContent);
            }
            var caseParameters = component.get("v.newCaseParameters");
            var newCase = {
                Topic__c: caseParameters.Topic,
                Sub_topic__c: caseParameters.Subtopic,
                Subject: emailContent.subject,
                Queue_Email__c: emailList[0]
            }
            newCase.AccountId = component.get("v.relatedAccountId");
            component.set('v.selectedCase', newCase);
            component.set('v.isCaseSelected', true);
        } else { 
            var selectedCase = component.get("v.backupCase");
            component.set('v.selectedCase', selectedCase);
            var emailContent = component.get("v.emailContent");
            if(type == 'Resend Invoice'){
                if(selectedCase){
                    emailContent.from = selectedCase.Queue_Email__c;
                    // emailContent.to = selectedCase.SuppliedEmail;
                    component.set('v.isCaseSelected', true);
                } else {
                    component.set('v.isCaseSelected', false);
                    emailContent.from = '';
                    emailContent.to = '';
                }
                component.set('v.emailContent', emailContent);   
            }
         
        }
    },

    handleCaseChanging: function(component, event, helper){
        helper.changeSubject(component, event);
    },

    getDocument: function(component, event, helper){
        var docNumber = event.target.name;
        var invoiceList = component.get("v.invoices");
        if(invoiceList){
            for(let i=0; i<invoiceList.length; i=i+1){
                if(invoiceList[i].name == docNumber){
                    invoiceList[i].loading = true;
                    invoiceList[i].isError = false;
                }
            }
        }
        component.set("v.invoices", invoiceList);
        helper.getDocument(component, docNumber, true);
    },

    openDocumentList: function(component, event, helper) {
        component.set("v.documentListOpened", true);
    },

    closeDocumentList : function(component, event) {
        let documentList = event.getParam("eventData");
        component.set("v.documentListOpened", false);
        // component.set("v.existingDocumentList", documentList);
        let existingDocumentList = component.get("v.existingDocumentList");
        existingDocumentList = existingDocumentList.concat(documentList);
        console.log('documentList end event === ', existingDocumentList);
        component.set("v.existingDocumentList", existingDocumentList);

    },

    removeDocFromList : function(component, event, helper) {
        let documentIdToRemove = event.target.name;
        console.log('documentIdToRemove === ', documentIdToRemove);
        let documentList = component.get("v.existingDocumentList");
        let deletedDocumentList = documentList.filter((doc) => {
            return doc.Id == documentIdToRemove;
        })
        documentList = documentList.filter((doc) => {
            return doc.Id != documentIdToRemove;
        })        
        for (let i = 0; i < deletedDocumentList.length; i++) {
            const element = deletedDocumentList[i];
            if(element.IsNew) {
                helper.deleteDocument(component, element.Id);
            }
        }
        component.set("v.existingDocumentList", documentList);
    },

    handleUploadFinished : function(component, event) {
        // Get the list of uploaded files
        let documentList = [];
        var uploadedFiles = event.getParam("files");
        for (let i = 0; i < uploadedFiles.length; i++) {
            const element = uploadedFiles[i];
            documentList.push({
                Id: element.documentId,
                Title : element.name,
                IsNew: true
            });
        }

        let existingDocumentList = component.get("v.existingDocumentList");
        existingDocumentList = existingDocumentList.concat(documentList);
        console.log('documentList end event === ', existingDocumentList);
        component.set("v.existingDocumentList", existingDocumentList);
    }
})