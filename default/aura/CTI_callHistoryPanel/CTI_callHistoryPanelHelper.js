({
    getCallHistory : function(component) {
        var action = component.get("c.getCallHistory");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var callHistory = this.prepareCallHistory(response.getReturnValue());
                component.set('v.callHistory', callHistory);
            }
            else{}
        })
        $A.enqueueAction(action);
    },

    prepareCallHistory : function(callHistoryItems) {

        console.log('=== HISTORY ===', callHistoryItems);
        var preparedCallHistory = [];
        if(callHistoryItems && callHistoryItems.length){
            for (var i = 0; i< callHistoryItems.length; i++) {
                var currentItem = callHistoryItems[i].historyItem;
                var gfnNumber = '';
                var accountId = '';
                var accountName = '';
                if(callHistoryItems[i].accountParams){
                    gfnNumber = callHistoryItems[i].accountParams.GFN_Nr__c;
                    accountId = callHistoryItems[i].accountParams.Id;
                    accountName = callHistoryItems[i].accountParams.Name;
                }
                preparedCallHistory.push({
                   Type : this.getCallType(currentItem),
                   PhoneNumber : currentItem.Phone_Number__c,
                   Time : $A.localizationService.formatDate(new Date(currentItem.Start_Time__c), "kk:mm:ss"),
                   GFNNumber : gfnNumber,
                   AccountId : accountId,
                   AccountName: accountName,
                   Duration : this.calculateDuration(currentItem),
                   StartTime : currentItem.Start_Time__c
               });
            }
            preparedCallHistory.sort((a, b)=>{
                var aTime = new Date(a.StartTime);
                var bTime = new Date(b.StartTime);
                if(aTime > bTime){
                    return -1;
                }
                if(aTime < bTime){
                    return 1;
                }
                return 0;
            });

        }
        return preparedCallHistory;
    },

    calculateDuration : function(currentItem) {
        var endTime = new Date(currentItem.End_Time__c);
        var startTime = new Date(currentItem.Start_Time__c);
        if(currentItem.Call_Type__c !== 'Missed' && !isNaN(startTime) && !isNaN(endTime)) {
            var duration = this.msToTime(endTime - startTime);
            return duration;
        } 
        else if(currentItem.Call_Type__c !== 'Missed' && (isNaN(startTime) || isNaN(endTime))) {
            return 'Unknown';
        }
        else {
            return '00:00'
        }

    },

    msToTime: function(s) {
        var ms = s % 1000;
        s = (s - ms) / 1000;
        var secs = s % 60;
        s = (s - secs) / 60;
        var mins = s % 60;
        var hrs = (s - mins) / 60;
      
        return hrs + ':' + mins + ':' + secs;
    },

    getCallType : function(currentItem) {
        if(currentItem.Action__c !== 'disconnected' && currentItem.Action__c !== 'established' && !currentItem.End_Time__c) {
            return 'Missed';
        }
        return currentItem.Call_Type__c;
    }

})
