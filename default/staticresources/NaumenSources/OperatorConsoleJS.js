/* Operator Console JS */
function initOperatorConsole (softphoneOriginURL) {
    // --- INIT OPERATOR CONSOLE ---
        var OPERATOR_CONSOLE = {
            recordId : null, // id of the customer record which will be opened in the operator console (Lead or Opportunity)
            callCustomerId : null, // id of the customer record or related records on which the call phone number is stored (Lead or Contact)
            phoneNumber : null, // call phone number
            extensionNumber : null, // extension number stored in SF for the curren call phone number
            callMode : null, // this value is set when processing mode is started (the call is finished)
            naumenProjectUUID : null, // UUID of the Naumen project from which the current call was initiated
            naumenCaseUUID : null, // UUID of the Naumen call case from which the call was initiated
            operatorName: null, // name of the operator for which the call was scheduled
            onActiveCallClosed: null, // function for processing event when call form is closed for the current call (the call is ended). Define this function in the custom jS to add custom logic for processing this event
    
            isTransferCallAvailable : function () { // defines a moment when operator is able to transfer the call to another Naumen operator
                return true;
            },
            clearCallParams: function () { // clear current active call info
                console.log('clear call params');
                OPERATOR_CONSOLE.callCustomerId = null;
                OPERATOR_CONSOLE.callMode = null;
                OPERATOR_CONSOLE.phoneNumber = null;
                OPERATOR_CONSOLE.extensionNumber = null;
                OPERATOR_CONSOLE.onActiveCallClosed = null;
            },
            clearCaseParams: function () { // clear info of the Naumen case which initiated the call
                console.log('clear case params');
                OPERATOR_CONSOLE.recordId = null;
                OPERATOR_CONSOLE.naumenProjectUUID = null;
                OPERATOR_CONSOLE.naumenCaseUUID = null;
                OPERATOR_CONSOLE.operatorName = null;
            },
         // ------- SET SOFTPHONE PARAMETERS ----------------------------------------------
            setSoftphoneParameters: function (saveCustomerCallInfo) { // set custom params for the softphone: rather call customer info will be saved in the softphone or not (saved in the operator console controller instead)
                this.postMessage_SetSoftphoneParameters(saveCustomerCallInfo);
            },
        // ------- CONSOLE METHODS ----------------------------------------------
            openRecordInConsole: null, // define this method in the custom JS to open a record in the operator console interface
            updateCallDataInConsole: null, // define this method in the custom JS to store new call data softphone sends (phone number, call mode)
            closeRecordInConsole: null, // define this method in the custom JS for closing the record in console (for example when processing is finished)
            saveRecordInConsole: null, // define this method in the custom JS for saving the current call data in console (for example when the second call is about to start)
    
        // ------- PROCESS SOFTPHONE EVENTS -----------------------------------------
            onOpenRecord: function () { // softphone sends a command to open the record which was found by current call params
                console.log('open record : ' + this.recordId + ' naumenProjectUUID : ' +  this.naumenProjectUUID + ' naumenCaseUUID : ' +  this.naumenCaseUUID + ' operatorName : ' +  this.operatorName + ' callMode : ' +  this.callMode);
                if (this.openRecordInConsole != null) this.openRecordInConsole(this.recordId, this.callCustomerId, this.phoneNumber, this.extensionNumber, this.naumenProjectUUID, this.naumenCaseUUID, this.operatorName, this.callMode);
            },
            onUpdateCallData: function () { // softphone sends info about updated call data
                console.log('update call data : phoneNumber : ' + this.phoneNumber + ' extensionNumber : ' +  this.extensionNumber + ' callMode : ' +  this.callMode);
                if (this.updateCallDataInConsole != null) this.updateCallDataInConsole(this.phoneNumber, this.extensionNumber, this.callMode);
            },
            onCloseRecord: function () { // softphone sends a command to close the record in the console (when processing is finished)
                console.log('close record in console');
                if (this.closeRecordInConsole != null) this.closeRecordInConsole();
            },
            onForceToSaveRecord: function () { // softphone sends a command to save the current call results in the console (when second call is about to start)
                console.log('save record in console (from softphone)');
                if (this.saveRecordInConsole != null) this.saveRecordInConsole();
            },
            onProcessingFinishedInConsole: function () { // softphone sends a command to save the current call results in the console (when second call is about to start)
                console.log('process event in console: Naumen form is closed');
                if (this.onActiveCallClosed != null) this.onActiveCallClosed();
            },
        // ------- PROCESS CONSOLE EVENTS -----------------------------------------
            onRecordOpenedInConsole: function (openedCallCustomerId) { // use this method in custom JS when customer record is successfully opened in the operator console
                console.log('onRecordOpenedInConsole >> openedCallCustomerId : ' + openedCallCustomerId + ' , this.callCustomerId : ' + this.callCustomerId);
                var recordParams = {};
                /*
                if(this.callCustomerId == null) {
                    this.callCustomerId = openedCallCustomerId; // 
                    recordParams.callCustomerId = openedCallCustomerId;
                }
                */
                recordParams.transferCallAvailable = this.isTransferCallAvailable(); // define if operator can transfer the call to another operator
                this.postMessage_RecordOpened(recordParams); //notify softphone that the record was opened in the operator console
            },
            onCallDataChanged: function (callData) { // notify softphone when call data was changed in the operator console
                console.log('onCallDataChanged');
                this.postMessage_ChangeCallData(callData);
            },
            onRecordSavedInConsole: function () { // notify softphone that call data was successfully saved
                console.log('onRecordSavedInConsole >> recordId : ' + this.recordId);
                this.postMessage_RecordSaved(this.recordId);
                OPERATOR_CONSOLE.clearCallParams();
            },
            onRecordClosedInConsole: function () { // process event when processing call case was successfully closed in the console
                console.log('onCaseClosedInConsole');
                OPERATOR_CONSOLE.clearCaseParams(); // clear Naumen call case info
            },
            onProcessingIsFinished: function () { // process event when processing of the Naumen call case was finished by operator in operator console
                console.log('onProcessingIsFinished');
                this.postMessage_CloseCall(); // send command to the softphone to close Naumen call form
            },
        // ------- CONSOLE PUSH EVENTS ----------------------------------------------
            postMessage_SetSoftphoneParameters: function (saveCustomerCallInfo) { // set params in softphone   
                var params = {saveCustomerCallInfo: saveCustomerCallInfo}; // define either call customer info will be saved in the softphone or not
                var data = {origin: 'OperatorConsole', event: 'setSoftphoneParams', params: params};
                parent.postMessage(data, softphoneOriginURL);
            },
            postMessage_RecordSaved: function (recordId) { // notification that record was successfully saved in the operator console
                var data = {origin: 'OperatorConsole', event: 'recordSaved', recordId: recordId};
                parent.postMessage(data, softphoneOriginURL);
            },
            postMessage_RecordOpened: function (recordParams) {  // notification that record was successfully opened in the operator console
                var data = {origin: 'OperatorConsole', event: 'recordOpened', params: recordParams};
                parent.postMessage(data, softphoneOriginURL);
            },
            postMessage_ChangeCallData: function (callData) { // send a command to softohone to update call data which was changed in the operator console
                var data = {origin: 'OperatorConsole', event: 'changeCallData', params: callData};
                parent.postMessage(data, softphoneOriginURL);
            },
            postMessage_CloseCall: function () { // send a command to softphone to close Naumen call form
                var data = {origin: 'OperatorConsole', event: 'closeCall'};
                parent.postMessage(data, softphoneOriginURL);
            },
        // ------- OPERATOR CONSOLE EVENTS LISTENERS -----------------------------------------
            processMessageEvent: function (e) {
                if (!softphoneOriginURL.startsWith(e.origin)) return;
                if (e.data.origin == 'NaumenDialer') {
                // open customer record in the console (customer which we found in the softphone)
                    if (e.data.event == 'openRecord') {
                        if (OPERATOR_CONSOLE.recordId == e.data.recordId) {
                            console.error('this record is already opened in the operator console!' + e.data.recordId);
                            return;
                        }
                        OPERATOR_CONSOLE.recordId = e.data.recordId; // opportunity id or lead id
                        OPERATOR_CONSOLE.callCustomerId = e.data.callCustomerId; // contact id or lead id
                        OPERATOR_CONSOLE.phoneNumber = e.data.phoneNumber; // naumen case phone number
                        OPERATOR_CONSOLE.extensionNumber = e.data.extensionNumber; // phone extension number
                        OPERATOR_CONSOLE.callMode = null; // this value is set when processing mode is started (the call is finished)
                        OPERATOR_CONSOLE.naumenProjectUUID = e.data.naumenProjectUUID; // naumen project UUID
                        OPERATOR_CONSOLE.naumenCaseUUID = e.data.naumenCaseUUID; // naumen case UUID
                        OPERATOR_CONSOLE.operatorName = e.data.operatorName; // phone extension number
                        OPERATOR_CONSOLE.onOpenRecord ();
                // update call data in the console (when operator's started a second call while processing the naumen case or when processing is started)
                    } else if (e.data.event == 'updateCallData') {
                        console.log('updatecalldata : ' + e.data.phoneNumber);
                        OPERATOR_CONSOLE.phoneNumber = e.data.phoneNumber; // naumen case phone number
                        OPERATOR_CONSOLE.extensionNumber = e.data.extensionNumber; // phone extension number
                        OPERATOR_CONSOLE.callMode = e.data.callMode; // this value is set when processing mode is started (the call is finished)
                        OPERATOR_CONSOLE.onUpdateCallData ();
                // close record in the console without saving it (when processing time is finished)
                    } else if (e.data.event == 'closeRecord') {
                        OPERATOR_CONSOLE.clearCallParams(); // clear currrent call data saved in the operator console
                        OPERATOR_CONSOLE.clearCaseParams(); // clear naumen case params which initiated the call
                        OPERATOR_CONSOLE.onCloseRecord();
                // softphone sends a command to save the current call data saved on the record (before starting a new call for the processing Naumen case)
                    } else if (e.data.event == 'saveRecord') {
                        OPERATOR_CONSOLE.onForceToSaveRecord();
                // notification that the call form was closed in Naumen
                    } else if (e.data.event == 'callClosed') {
                        OPERATOR_CONSOLE.onProcessingFinishedInConsole();
                    }
                }
            }
        }
    // --- ADD WINDOW EVENT LISTENERS ---
        window.addEventListener ("message", OPERATOR_CONSOLE.processMessageEvent);
        return OPERATOR_CONSOLE;
    }
    