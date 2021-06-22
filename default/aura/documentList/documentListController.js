({
    doInit : function(component, event, helper){
        helper.getUsersDocumentList(component);
        helper.getDocumentAndLibraries(component);
    },

    openLibrary : function(component, event) {
        let selectedItem = event.currentTarget;
        let libId = selectedItem.dataset.libid;
        console.log('selectedItem.dataset', selectedItem.dataset);

        console.log('libId', libId);
        component.set("v.openedLibraryId", libId);
    },

    openMyDocs : function(component, event) {
        component.set("v.librariesOpened", false);
        component.set("v.ownedByMeDocsOpened", true);
    },

    openLibraryList : function(component, event) {
        component.set("v.librariesOpened", true);
        component.set("v.ownedByMeDocsOpened", false);
    },

    addDocumentToEmail : function(component) {
        let selectedDocumentList = [];
        let documentCheckboxList = component.find("document-selection");
        if(documentCheckboxList) {
            if(documentCheckboxList.length) {
                for(let i = 0; i < documentCheckboxList.length; i++) {
                    let documentCheckbox = documentCheckboxList[i];
                    if(documentCheckbox.get("v.checked")) {
                        selectedDocumentList.push({
                            Id : documentCheckbox.get("v.value"),
                            Title : documentCheckbox.get("v.name"),
                        });
                    }                    
                }
            }
            else {
                if(documentCheckboxList.get("v.checked")) {
                    selectedDocumentList.push({
                        Id : documentCheckboxList.get("v.value"),
                        Title : documentCheckboxList.get("v.name"),
                    });
                }
            }
        }
        console.log('selectedDocumentList=== ', selectedDocumentList);
        var compEvent = component.getEvent("closeDocumentList");
        compEvent.setParams({"eventData":selectedDocumentList});
        compEvent.fire();
    },

    closeModal : function(component, event) {
        var compEvent = component.getEvent("closeDocumentList");
        compEvent.setParams({"eventData":[]});
        compEvent.fire();
    }
})
