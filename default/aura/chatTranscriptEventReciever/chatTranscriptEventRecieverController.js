({
    doInit : function(component) {
        component.set("v.timestamp", new Date());
    },
   
    onChatEnded: function(cmp, evt, helper) {
       
        let recordId = evt.getParam( "recordId" );
        let actualRecordId = cmp.get("v.recordId");
        console.log('recordId===', recordId);
        console.log('actualRecordId===', actualRecordId);
        if(recordId && actualRecordId && recordId.substring(0,15) == actualRecordId.substring(0,15)) {
            let timestamp = cmp.get("v.timestamp");
            let dateTimeStamp = new Date(timestamp);
            let expectedDate = new Date(dateTimeStamp.getTime()+ 600000); //+1 min
            console.log(dateTimeStamp);
            var today = new Date();
            if(today > expectedDate) {
                let workspaceAPI = cmp.find( "workspace" );
                workspaceAPI.getEnclosingTabId().then( function( enclosingTabId ) {
                    workspaceAPI.getFocusedTabInfo().then( function( response ) {
                        var focusedTabId = response.tabId;
                        if(focusedTabId != enclosingTabId) {
                            workspaceAPI.closeTab( { tabId: enclosingTabId } );
                        }
                    })
                })
                .catch(function( error ) {
                    console.log( 'Error is' + JSON.stringify( error ) );
                });
            }
        }
       
    },

    onNewMessage: function(cmp, evt, helper) {
        let recordId = evt.getParam('recordId');
        let timestamp = evt.getParam('timestamp');
        let dateTimeStamp = new Date(timestamp);
        console.log(dateTimeStamp);
        
        let actualRecordId = cmp.get("v.recordId");
        if(actualRecordId == recordId) {
            cmp.set("v.timestamp", timestamp);
        }
    }
   

})