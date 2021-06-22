({
    getDocumentAndLibraries : function(component) {
        var action = component.get("c.getDocuments");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                console.log('SUCCESS');
                let returnValue = response.getReturnValue();
                this.setLibraryList(returnValue, component);
                component.set("v.documentList", returnValue);
            } else {
                console.log('Error');
                console.log(response.getError());
            }          
        })
        $A.enqueueAction(action);
    },


    getUsersDocumentList : function(component) {
        var action = component.get("c.getUsersDocuments");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                console.log('SUCCESS');
                console.log(response.getReturnValue());
                component.set("v.ownedByMeDocs", response.getReturnValue());
            } else {
                console.log('Error');
                console.log(response.getError());
            }          
        })
        $A.enqueueAction(action);
    },


    setLibraryList : function(returnValue, component) {
        let libraryList = [];
        for(let i = 0; i < returnValue.length; i++) {
            if ((!libraryList.filter(library => library.Id === returnValue[i].ContentWorkspaceId).length > 0)){
                libraryList.push({
                    Id : returnValue[i].ContentWorkspaceId,
                    Name : returnValue[i].ContentWorkspace.Name
                });
            }
        }
        console.log('=== libraryList === ', libraryList );
        component.set("v.libraryList", libraryList);
    }
})
