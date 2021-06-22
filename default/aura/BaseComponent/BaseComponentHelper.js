({
    callServerMethod: function(component,apexMethodName,apexParams,successCallBack,errorCallBack,ignoreCache) {
        if (!apexMethodName ){
            return;
        }    
        var action = component.get(apexMethodName);
        if (apexParams){
            action.setParams(apexParams);
        }
        if(ignoreCache){
            action.setStorable({ignoreExisting:ignoreCache});
        }
        action.setCallback(this, function(response) {
            try{
                if (component.isValid() && response.getState() === "SUCCESS") {
                    successCallBack(response, component);
                } else if (response.getState() === "ERROR") {
                    errorCallBack(response);
                }
                component.set('v.loaded', true);
            } catch (e){             
                console.log('error', e);
                component.set('v.loaded', true);
            }
        });
        $A.enqueueAction(action);
      },

      showInfoToast: function(message, type, title, sticky){
          try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": type,
                "title": title,
                "message": message,
                "duration": 10000
            });
            toastEvent.fire();
          } catch (error) {
              alert(message);
          }

    },
    
    handleErrorState: function(response, errorSource, component){
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                this.showInfoToast(errorSource + " Error: " + errors[0].message.replace('<br/>', '\n'), "error", "Error!");
                console.log('Error:', errors[0].message);
            }
        } else {
            this.showInfoToast(errorSource + " Error: Unexpected error", "error", "Error!");
        }
        component.set("v.errorMessage", "Error");
    },

    prepareGFNParameters: function(event, gfnParameters, component) {
        var gfnParams;
        if(gfnParameters && gfnParameters[0] && gfnParameters[1]){
            gfnParams = gfnParameters
        } else if(event && event.getParam("value")) {
            gfnParams = event.getParam("value").split(',');
        } else{
            return null;
        }      
        var colCoID = gfnParams[0];
        var customerNumber = gfnParams[1];
        return {
            "colCoID": colCoID,
            "customerNumber": customerNumber,
            "lineOfBusiness": component.get("v.lineOfBusiness")
        }
    },

    formatDate: function(inputDate, withoutTime, offset){
        var date = new Date(inputDate);
        if(date instanceof Date && !isNaN(date)){
            if(withoutTime){
                return $A.localizationService.formatDate(date, "dd/MM/yyyy");
            } else{
                if(offset){
                    date.setTime(date.getTime()+offset);
                }
                return $A.localizationService.formatDate(date, "dd/MM/yyyy kk:mm");
            }
            
        }
        return null;
    },

    setCookie: function(name, value, expirationTime){
        var date = new Date();
        date.setTime(date.getTime() + (expirationTime * 60 * 1000));
        var expires = "expires="+date.toUTCString();
        document.cookie = name + "=" + value + ";" + expires + ";path=/";
    },

    getCookie: function(cname){
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return ""
    }

})