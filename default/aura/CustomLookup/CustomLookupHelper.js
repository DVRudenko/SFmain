({
    searchHelper : function(component,event,getInputkeyWord) {
      // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method
        var fieldForSearch = component.get("v.fieldForSearch");
        action.setParams({
              'searchKeyWord': getInputkeyWord,
              'objectName' : component.get("v.objectAPIName"),
              'fieldForSearch' : fieldForSearch
            });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    if (storeResponse.length == 0) {
                      component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                        if(fieldForSearch !== 'Name') {
                            this.prepareResults(storeResponse, fieldForSearch);
                        }
                    }
                  // set searchResult list with return value from server.
                    component.set("v.listOfSearchRecords", storeResponse);
                }
  
        });
        // enqueue the Action  
        $A.enqueueAction(action);
      
    },

    prepareResults : function(results, fieldForSearch) {
        for(let i = 0; i < results.length; i++) {
            results[i].Name = results[i][fieldForSearch];
        }
    }
  
})
 