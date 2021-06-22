({
    getCaseList : function(component) {
        var recordId = component.get("v.recordId");
        var objectName = component.get("v.objectName");
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            var action = component.get("c.getCasesByERP");
            action.setParams({
                customerERP: gfnParams[1]
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var cases = response.getReturnValue();
                    var accountId;
                    var erpId;
                    if(cases){
                        component.set('v.caseList', cases);
                        if(objectName === 'Account'){
                            accountId = recordId;
                        } else if (objectName === 'ERP__c') {
                            erpId = recordId;
                        } else {
                            if(cases[0]){
                                accountId = cases[0].AccountId;
                                erpId = cases[0].ERP__c
                            }
                        }
                        component.set('v.relatedAccountId', accountId);
                        component.set('v.relatedERP', erpId);
                        if(cases[0]){
                            component.set('v.emailContent', {
                                from: cases[0].Queue_Email__c,
                                to: cases[0].SuppliedEmail,
                                subject:'',
                                body:'',
                                cc: ''
                            });
                        }                    
                    }
                    var type = component.get("v.type");
                    let lob = component.get("v.recordType");
                    if(lob == 'SME') {
                        this.getContacts(component, accountId);
                    } else {
                        this.getContactsByERP(component, erpId);
                    }
                    if(type=='Resend PIN'){
                        this.setEmail(component);
                    } else {
                        this.getTemplate(component);                    
                    }
                    this.getQueueEmails(component);
                } else {
                    console.log('Error', response.getReturnValue());
                }
                component.set('v.caseLoaded', true);
            });
            $A.enqueueAction(action);
        }
    },

    getQueueEmails : function(component) {
        var action = component.get("c.getQueueEmailList");
        var accParams = component.get("v.accParams");
        action.setParams({
            accParams : accParams
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue){
                    component.set('v.queueEmailList', returnValue);
                }
            }
        });
        $A.enqueueAction(action);
    },

    sendEmail : function(component) {
        var relatedAccount = component.get("v.relatedAccountId");
        var relatedERP = component.get("v.relatedERP");
        var relatedCase = component.get("v.selectedCase");
        var emailContent = component.get("v.emailContent");
        var isNewCase = component.get("v.isNewCase");
        var invoices = component.get("v.invoices");
        var documents = component.get("v.existingDocumentList");
        var documentIdList = [];
        for(let i = 0; i < documents.length; i++) {
            documentIdList.push(documents[i].Id);
        }
        console.log('documentIdList ===', documentIdList);
        emailContent.body = this.updateEmailBodyForCorrectDisplaying(emailContent.body);
        if(isNewCase && relatedAccount){
            relatedCase.AccountId = relatedAccount;
        }
        if(isNewCase && relatedERP){
            relatedCase.ERP__c = relatedERP;
        }
        if(invoices && invoices.length){
            var pdfList = {};
            for(var i=0; i<invoices.length; i = i+1){
                if(!invoices[i].isError){
                    pdfList[invoices[i].name] = invoices[i].url.replace("data:application/octet-stream;charset=utf-16le;base64,", "");
                }
            }
            invoices = JSON.stringify(pdfList);
            emailContent.invoices = invoices;
        }
        var action = component.get("c.createCaseAndSendEmail");
        action.setParams({
            isNewCase: isNewCase,
            relatedCase : relatedCase,
            emailContent : emailContent,
            lineOfBusiness : component.get("v.recordType"),
            documentsToAttach : documentIdList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                this.showInfoToast("Email was sent", "Success", "Success", true);
                var closeEvent = component.getEvent("ResendInvoiceButtonEvent");
                closeEvent.setParams({"isResendInvoicePopupOpened":false});
                closeEvent.fire();
            } else {
                var error = response.getError();
                if(error && error[0]){
                    this.showInfoToast("Error", "Error", error[0].message, true);
                } else {
                    this.showInfoToast("Error", "Error", "Error", true);
                }
                console.log('error', response.getError());
            }
            component.set('v.loaded', true);            
        })
        $A.enqueueAction(action);
    },

    getInvoices : function(component){
        component.set('v.isInvoicesLoaded', false);
        var docNumbers = component.get("v.docNumberList");
        if(docNumbers && Array.isArray(docNumbers) && docNumbers.length){
            var gfnParams = component.get("v.gfnParams");
            if(gfnParams){
                gfnParams = gfnParams.split(',');
                for(let i = 0; i < docNumbers.length; i=i+1){
                    var action = component.get("c.getPDFInvoice");
                    action.setParams({
                        docNumber: docNumbers[i],
                        colCoID: gfnParams[0],
                        customerERP: gfnParams[1],
                        recordTypeName : component.get("v.recordType")
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        var invoices = component.get("v.invoices");
                        if (state === "SUCCESS") {
                            var encodedPDF = response.getReturnValue();
                            invoices.push({
                                url: "data:application/octet-stream;charset=utf-16le;base64,"+encodedPDF,
                                name: docNumbers[i],
                                isError: encodedPDF == ''
                            });
                            component.set('v.invoices', invoices);
                        } else {
                            var invoices = component.get("v.invoices");
                            invoices.push({
                                url: "",
                                name: docNumbers[i],
                                isError: true
                            });         
                            component.set('v.invoices', invoices);
                        }
                        if(i==(docNumbers.length-1)){
                            var errorInvoices = invoices.filter(function(invoice){
                                return invoice.isError
                            });
                            if(errorInvoices && errorInvoices.length){
                                this.showInfoToast('error', 'Error', 'Some files were not uploaded successfully', true);
                            }
                        }
                        component.set('v.isInvoicesLoaded', true);
                    });
                    $A.enqueueAction(action);
                }
            } else {
                component.set('v.isInvoicesLoaded', true);
            }
        } else{
            component.set('v.isInvoicesLoaded', true);
        }   
    },

    getTemplate : function(component){
        var accParams = component.get("v.accParams");
        if(accParams){
            this.getTemplateByParams(component, accParams);
        } else {
            this.getAccParamsAndTemplate(component);
        }
    },

    getContacts : function(component, accountId){
        var action = component.get("c.getContactList");
        action.setParams({
            accountId : accountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contacts = response.getReturnValue();
                component.set('v.contactList', contacts);
            }
        });
        $A.enqueueAction(action);
    },

    getContactsByERP : function(component, erpId){
        var action = component.get("c.getContactsByERP");
        action.setParams({
            erpId : erpId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contacts = response.getReturnValue();
                component.set('v.contactList', contacts);
            }
        });
        $A.enqueueAction(action);
    },

    changeSubject : function(component, event){
        var newCase = event.getParam("value");
        var oldCase = event.getParam("oldValue");
        var email = component.get("v.emailContent");
        if(oldCase && oldCase.CaseNumber && newCase){
            email.subject = email.subject.replace(oldCase.CaseNumber, newCase.CaseNumber);
        } else if(newCase && newCase.CaseNumber){
            email.subject = email.subject.replace('(New Case)', newCase.CaseNumber);
        }
        component.set('v.email', email);    
        
    },

    showInfoToast: function(message, type, title, sticky){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message,
            "sticky": sticky
        });
        toastEvent.fire();
    },

    getDocument: function(component, docNumber, isExisting){
        this.createGetDocumentAction(
            component,
            docNumber,
            (response)=>{
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var returnValue = response.getReturnValue();
                    if(returnValue){
                        var encodedPDF = response.getReturnValue();
                        var invoices = component.get("v.invoices");
                        if(!isExisting){
                            invoices.push({
                                url: "data:application/octet-stream;charset=utf-16le;base64,"+encodedPDF,
                                name: docNumber,
                                isError: encodedPDF == ''
                            });
                            component.set('v.invoices', invoices);                        
                        } else {
                            if(invoices){
                                for(var i = 0; i < invoices.length; i=i+1){
                                    if(invoices[i].name == docNumber){
                                        invoices[i].url = "data:application/octet-stream;charset=utf-16le;base64,"+encodedPDF;
                                        invoices[i].isError = encodedPDF == '';
                                        invoices[i].loading = false;
                                    }
                                }
                                component.set('v.invoices', invoices);
                            }
                        }
                    }
                } else {
                    this.showInfoToast("Error", "Error", 'Some files were not uploaded successfully', true);
                    var invoices = component.get("v.invoices");
                    if(invoices){
                        for(var i = 0; i < invoices.length; i=i+1){
                            if(invoices[i].name == docNumber){
                                invoices[i].loading = false;
                                invoices[i].isError = true;
                            }
                        }
                        component.set('v.invoices', invoices);
                    }
                }
            }
        )
    },

    createGetDocumentAction: function(component, docNumber, callBack){
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            var action = component.get("c.getPDFInvoice");
            action.setParams({
                docNumber: docNumber,
                colCoID: gfnParams[0],
                customerERP: gfnParams[1],
                recordTypeName : component.get("v.recordType")
            });
            action.setCallback(this, callBack);
            $A.enqueueAction(action);
        }
    },

    getAccParamsAndTemplate: function(component, address){
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            var action = component.get("c.getAccParams");
            action.setParams({
                colCoId: gfnParams[0],
                customerNumber: gfnParams[1],
                recordTypeName : component.get("v.recordType")

            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var accDetails = response.getReturnValue();
                    if(accDetails){
                        accDetails = JSON.parse(accDetails);
                    }
                    var accParams = accDetails.Language + ',' + gfnParams[0];
                    var companyName = accDetails.FullName;
                    component.set('v.companyName', companyName);
                    component.set('v.accParams', accParams);
                    var type = component.get("v.type");
                    if(type == 'Resend PIN'){
                        this.setUpEmailContent(component, address);
                    } else {
                        this.getTemplateByParams(component, accParams);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    getTemplateByParams: function (component, accParams) {
        var action = component.get("c.getEmailTemplate");
        action.setParams({
            accParams: accParams
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var template = response.getReturnValue();
                var email = component.get("v.emailContent");
                var selectedCase = component.get("v.selectedCase");
                if(template){
                    if(template.Subject && selectedCase){
                        email.subject = template.Subject.replace('{!Case.CaseNumber}', selectedCase.CaseNumber);
                        email.subject = template.Subject.replace('(New Case)', selectedCase.CaseNumber);
                    } else if(!selectedCase){
                        email.subject = template.Subject.replace('{!Case.CaseNumber}', '(New Case)');
                    }else {
                        email.subject = template.Subject;
                    }
                    var templateHtmlValue = template.HtmlValue;
                    if(templateHtmlValue){
                        templateHtmlValue = templateHtmlValue.split("Margin: 0 auto").join('');
                        templateHtmlValue = templateHtmlValue.split('align="center"').join('');
                    }
                    templateHtmlValue = templateHtmlValue.replace(/<\/?table[^>]*>/g, '');
                    email.body = templateHtmlValue;
                }
                component.set('v.emailContent', email);
            }
            this.getInvoices(component);
            component.set('v.templateLoaded', true);
        });
        $A.enqueueAction(action);        
    },

    setEmail: function(component){
        var address = component.get("v.address");
        if(address){
            var companyName = component.get("v.companyName");
            if(companyName){
                this.setUpEmailContent(component, address);
            } else {
                this.getAccParamsAndTemplate(component, address);
            }
        } else {
            this.getAddressAndSetEmail(component);
        }
    },

    getAddressAndSetEmail: function(component){
        var gfnParams = component.get("v.gfnParams");
        if(gfnParams){
            gfnParams = gfnParams.split(',');
            var action = component.get("c.getAddressFromGFN");
            action.setParams({
                colCoId: gfnParams[0],
                customerNumber: gfnParams[1],
                recordTypeName : component.get("v.recordType")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var addressesString = response.getReturnValue();
                    if(addressesString){
                        var addresses = JSON.parse(addressesString);
                        var address;
                        if(addresses && Array.isArray(addresses) && addresses.length){
                            for(var i = 0; i<addresses.length; i=i+1){
                                var addressTypes = addresses[i].AddressTypes.filter((currentAddress)=>{
                                    return currentAddress.AddressType == 'Card Delivery' || currentAddress.AddressType == 'Pin Delivery'
                                });
                                if(addressTypes && addressTypes[0]){
                                    component.set('v.address', addresses[i]);
                                    address = addresses[i];
                                    break;
                                }
                            }                            
                        } 
                        var companyName = component.get("v.companyName");
                        if(companyName){
                            this.setUpEmailContent(component, address);
                        } else {
                            this.getAccParamsAndTemplate(component, address);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    
    setUpEmailContent: function(component, address){
        var cardList = component.get("v.cards");
        var email = component.get("v.emailContent");
        var companyName = component.get("v.companyName");
        var accParams = component.get("v.accParams");
        email.body = 
        '<![CDATA[<div><div style="color: rgb(0, 0, 0); font-family: arial;">'+
        
        "<i>Dear Shell, <br/>As Shell Card reseller, we would like to request a pin reminder for one of our end customers. Please find the card and address details below.</i><br/><br/>"+
        "<b><i>RESEND PIN</i></b><br/>";
        if(Array.isArray(cardList) && cardList.length){
            for(var i = 0; i<cardList.length; i=i+1){
                email.body += "Card number: " + cardList[i].PAN + '<br/>';
                email.body += "Card embossing: " + this.getEmbossing(cardList[i]) + '<br/>'
            }
        }
        email.body += '<br/><b>Address</b><br/>';
        email.body += '<b>'+companyName+'</b><br/>';
        email.body += address.AddressLines + '<br/>';
        if(address.Region && address.Region != ''){
            email.body += address.Region + '<br/>';
        }
        email.body += address.ZipCode + '<br/>';
        email.body += address.City + '<br/>';
        email.body += address.Country + '<br/><br/>';
        
        email.body += 'Please confirm once completed. <br/><br/>';
        email.body += '<i>Thank you, </i><br/>';
        email.body += '<i>FLEETCOR</i></div></div>';

        email.subject = 'Resend PIN for FLEETCOR customer';
        email.to = this.getPlatinumEmail(accParams);
        email.from = this.getEmailAddress(accParams);
        component.set('v.emailContent', email);
        component.set('v.templateLoaded', true);
    },

    getEmbossing: function (card) {
        var embossingParams = [];
        if(card.RegNumber && card.RegNumber!="" && card.RegNumber!=" "){
            embossingParams.push(card.RegNumber);
        } 
        if(card.DriverName && card.RegNumber!="" && card.RegNumber!=" "){
            embossingParams.push(card.DriverName);
        }
        return embossingParams.join(', ');
    },

    getPlatinumEmail: function(accParams){
        var emailMap = {
            'German,1': 'card-grosskundenbetreuung-at@shell.com',
            'German,2': 'card-grosskundenbetreuung-at@shell.com',
            'German,80': 'keyaccount-card-ch@shell.com',
            'French,80': 'keyaccount-card-ch@shell.com',
            'Italian,80': 'keyaccount-card-ch@shell.com',
            'Dutch,4': 'nl-platinumshellcard@shell.com',
            'Dutch,3': 'keyaccountcardenquiries-be@shell.com',
            'French,3': 'keyaccountcardenquiries-be@shell.com',
            'French,5': 'demandescartegrandcompte-fr@shell.com',
            'French,79': 'keyaccountcardenquiries-lu@shell.com',
            'Hungarian,6': 'platinum-hu@shell.com',
            'Polish,7': 'kartyVIP-pl@shell.com',
            'Czech,81': 'karty-customercare-cz@shell.com',
            'Slovak,82': 'karty-customercare-sk@shell.com',
        }
        return emailMap[accParams];
    },

    getEmailAddress: function(accParams){
        var emailMap = {
            'German,1': 'kundenservice@fleetcor.de',
            'German,2': 'kundenservice@fleetcor.at',
            'German,80': 'kundenservice@fleetcor.ch',
            'French,80': 'serviceclients@fleetcor.ch',
            'Italian,80': 'servizioclienti@fleetcor.ch',
            'Dutch,4': 'klantenservice@fleetcor.nl',
            'Dutch,3': 'klantendienst@fleetcorcards.be',
            'French,3': 'serviceclients@fleetcorcards.be',
            'French,5': 'serviceclients@fleetcor.fr',
            'French,79': 'serviceclients@fleetcor.lu',
            'Hungarian,6': 'ugyfelszolgalat@fleetcor.hu',
            'Polish,7': 'obslugaklienta@fleetcor.pl',
            'Czech,81': 'zakaznickyservis@fleetcor.cz',
            'Slovak,82': 'zakaznickyservis@fleetcor.sk',
        }
        return emailMap[accParams];
    },

    updateEmailBodyForCorrectDisplaying: function(emailBody){
        var editedEmailBody = emailBody.replace(/<p style="text-align: justify;"><br><\/p>/g, "<br/>");
        editedEmailBody = editedEmailBody.replace(/<p[^>]*>/g, "<br/>");
        editedEmailBody = editedEmailBody.replace(/<\/p>/g, "");
        editedEmailBody = '<table><tbody><tr><td><div style="color:black;font-family:Arial, \'Helvetica Neue\', Helvetica, sans-serif;line-height:120%;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">' + editedEmailBody + '</div></td></tr></tbody></table>';
        return editedEmailBody;
    },


    deleteDocument: function(component, docId) {
        var action = component.get("c.deleteNewDocument");
        action.setParams({
            docId: docId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(docId + ' DELETED');
            }
            else {
                console.log('ERROR');
                console.log(response.getError());
            }
        })
        $A.enqueueAction(action);
    }
})