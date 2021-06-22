/* Naumen SoftPhone JS */
var SoftphoneApp = angular.module('SoftphoneApp', []);
SoftphoneApp.controller('SoftphoneController', function($scope) {
    
// ---- naumen connection data ----
    $scope.softphoneURL;
    $scope.NauPhone; // nauphone js methods
    
// ---- call data ----
    $scope.call = null; // current call 
    /* blockedCalls are not being used now - we process all calls: inbound, outbound and autocalls
        $scope.blockedCalls = []; // calls which wern't processed (we only process certain types of calls, for ex - autocalls)
    */


 // ------- INIT SOFTPHONE----------------------------------------------
    $scope.init = function (softphoneURL, wsURL) {
    // --- ADD WINDOW EVENT LISTENERS -----------------
        window.addEventListener ("message", $scope.processMessageEvent);

    // --- INIT NAUPHONE ----------------
        // sotphone params
        $scope.NaumenReady = false;
        $scope.softphoneURL = softphoneURL;
        $scope.NauPhone = getNauPhone(wsURL);
        $scope.saveCustomerCallInfo = false; // set this parameter as true if need to save call data in softphone controller (not in any other controller as RecordAssignCheckRuDemoCtrl)
        // connect to Naumen
        $scope.NauPhone.connect().then(function () {
            console.log('NauPhone.connect ');
         // -- set Nauphone events listners  
            $scope.NauPhone.emitter.on('userstate', function (userState) {
                $scope.onUserStateChanged(userState);
            });
            $scope.NauPhone.emitter.on('newcall', function (call) {
                $scope.onNewCall(call);
            });
            $scope.NauPhone.emitter.on('onclose', function (call) { // when Naumen form is closed
                console.log('>> onclose >> ', call);
                if ($scope.userState.state == 'wrapup') {
                    $scope.closeCurrentCall();
                }
            });
            $scope.NauPhone.emitter.on('disconnected', function () {
                $scope.onNauphoneDisconnected();
            });
            $scope.NauPhone.emitter.on('callstatus', function (call) {
                $scope.onCallstatus(call);
            });
            $scope.NauPhone.emitter.on('transferSucceed', function (call) {
                console.log('transferSucceed' + ': ' + JSON.stringify(call));
            });
            $scope.NauPhone.emitter.on('transferFailed', function (call) {
                $scope.onTransferFailed(call);
            });
            $scope.NauPhone.emitter.on('transferCallReturned', function (call) {
                console.log('transferCallReturned' + ': ' + JSON.stringify(call));
            });
        // -- start softphone 
            $scope.onNauphoneConnected();
        }, function(reason) {
            console.error('Naumen connection is failed! ' + reason); // Ошибка!
            $scope.hideSoftphone();
        });
   
    }
// ------- NAUPHONE EVENT HANDLERS ----------------------------------------------
// --- connected/disconnected websocket events ------------------
    $scope.onNauphoneConnected = function () {
        console.log('>> onNauphoneConnected >> ');
    // -- set user state
        $scope.NauPhone.getUserState().then(function (userState) {
            console.log('User state : ', userState);
            $scope.NaumenReady = true;
            $scope.userState = userState;
            $scope.userState.stateLabel = getUserStateLabel(userState.state, userState.reason);
            $scope.$apply();
            $scope.toStartMode();
        });
    // -- pop up softphone on the page
        $scope.showSoftphone();
    }
    $scope.onNauphoneDisconnected = function () {
        console.error('>> onNauphoneDisconnected >> ');
        $scope.NaumenReady = false;
        var headerText = 'DISCONNECTED';
        var msgText = $label_Naumen_notifMsg_SoftphoneDisconnected;
        $scope.showNotification ('error', headerText, msgText);
        $scope.$apply();
    }
// --- user state events ------------------
    $scope.onUserStateChanged = function (userState) {
        console.log('>> onUserStateChanged >> from: ' + $scope.userState.state + ' : ' + $scope.userState.reason + ' : to : ' + userState.state + ' : ' + userState.reason);
		if (userState.state == 'normal' && $scope.call != null &&
                                               ($scope.call.callState.state == 'new' // user state is moved from "ringing" to "normal" (operator didn't answer the call)
                                             || $scope.userState.state == 'wrapup') // user state is moved from "wrapup" to "normal" (that can happen since we work with Naumen forms which move user state to "wrapup")
        ) {
            $scope.endCall(true); // clear call data
        }
        $scope.userState = userState;
        $scope.userState.stateLabel = getUserStateLabel(userState.state, userState.reason);
        $scope.$apply();
    }
// --- call events ------------------
    $scope.onNewCall = function (call) {
        console.log('>> onNewCall >> ', call);
        if($scope.call == null) {
            $scope.createNewCall(call);
        } else {
            try {
                call.getParams().then(function (params) {
                    if (params != null && params.direction == '') return; // ignore  calls with empty params. Ex call: {"id":20,"params":{"called":"","caller":"","direction":"","seanceId":"0","url":"http://172.20.136.82/fx/auth"}}
                    if(userState.state == 'normal') $scope.setUserState('dnd');
                    $scope.showNotification ('notification', $label_Naumen_notifheader_CantOpenTheCall, $label_Naumen_notifMsg_ThereIsAnActiveCall + ' New call : ' + JSON.stringify(params) + '. Active call : ' + JSON.stringify($scope.call));
                });
            } catch (ex) {
                console.error(ex);
                if(userState.state == 'normal') $scope.setUserState('dnd');
                $scope.showNotification ('notification', $label_Naumen_notifheader_CantOpenTheCall, $label_Naumen_notifMsg_ThereIsAnActiveCall + ' New call : ' + JSON.stringify(call) + '. Active call : ' + JSON.stringify($scope.call));
            }
        }
    }
    $scope.onCallstatus = function (call) {
        call.getState().then($scope.updateCallState, $scope.updateCallState);
    }
    $scope.onTransferFailed = function (call) {
        console.log('>> onTransferFailed >> ', call);
        if (call.id == $scope.call.callParams.id) {
            $scope.call.transfered = false;
            $scope.$apply();
        }
    }
// ------- SOFTPHONE PUSH POSTMESSAGE EVENTS ----------------------------------------------
// --- open record in operator console ------------------
    // this event is used for opening record card when call is started
    $scope.postMessage_openRecord = function () {
        var data = {origin: 'NaumenDialer', 
                    event: 'openRecord', 
                    recordId: $scope.call.customer.recordId, // opportunity id or lead id
                    callCustomerId: $scope.call.customer.callCustomerId, // contact id or lead id
                    phoneNumber: $scope.call.phoneNumber,  // naumen case phone number
                    extensionNumber: $scope.call.customer == null ? '' : $scope.call.customer.extensionNumber, // extension number 
                    naumenProjectUUID: $scope.getNaumenProjectUUID(), // naumen project UUID
                    naumenCaseUUID: $scope.getNaumenCaseUUID(), // naumen case UUID
                    operatorName: $scope.call.operatorName
        };
        parent.postMessage(data, $scope.softphoneURL);
    }
// --- update call data in console ------------------
    // this event is used to send call data in the console when the call is created and finished
    $scope.postMessage_updateCallData = function () {
        var callModeToSend = $scope.call.stateMode == "PROCESSING" ? $scope.call.stateMode : null;// for now we only need to know in console when processing mode is set
        var data = {origin: 'NaumenDialer', 
                    event: 'updateCallData', 
                    phoneNumber: $scope.call.phoneNumber,  // naumen case phone number
                    extensionNumber: $scope.call.customer == null ? '' : $scope.call.customer.extensionNumber, // extension number
                    callMode: callModeToSend  // this value is set when processing mode is started (the call is finished)
        };
        parent.postMessage(data, $scope.softphoneURL);
    }
// --- force console to save current record ------------------
    // this event is used when operator makes second phone call while processing the first call (immediateCall)
    $scope.postMessage_saveRecord = function () {
        var data = {origin: 'NaumenDialer', 
                    event: 'saveRecord'
        };
        parent.postMessage(data, $scope.softphoneURL);
    }
// --- force console to close current record without saving it ------------------
    // this event is used for closing current record in the console when processing time is over
    $scope.postMessage_closeRecord = function () {
        var data = {origin: 'NaumenDialer', 
                    event: 'closeRecord'
        };
        parent.postMessage(data, $scope.softphoneURL);
    }
// --- notify console that new call is started in softphone ------------------
    // this event is used when we get event from Naumen about a new call
    $scope.postMessage_callCreated = function () {
        console.log('postMessage_callCreated');
        var data = {origin: 'NaumenDialer', 
                    event: 'callCreated'
        };
        parent.postMessage(data, $scope.softphoneURL);
    }
// --- notify console that call form is closed in naumen ------------------
    // this event is used as an answer on request from console to close the call
    $scope.postMessage_callClosed = function () {
        console.log('postMessage_callClosed');
        var data = {origin: 'NaumenDialer', 
                    event: 'callClosed'
        };
        parent.postMessage(data, $scope.softphoneURL);
    }
// ------- SOFTPHONE EVENTS LISTENERS -----------------------------------------
    $scope.processMessageEvent = function (e) {
    // message events from operator console
        if (e.data.origin == 'OperatorConsole') {
        // record was saved in the console (processing is finished)
            if (e.data.event == 'recordSaved') {
                $scope.onRecordSaved (e.data.recordId);
        // record was succesfully opened in the operator console
            } else if (e.data.event == 'recordOpened') {
                var recordParams = e.data.params;
                if (recordParams.callCustomerId != null) {
                    $scope.onCallCustomerFound (recordParams.callCustomerId);
                }
                $scope.transferCallAvailable = recordParams.transferCallAvailable;
        // set softphone params for needed for working with the current operator console
            } else if (e.data.event == 'setSoftphoneParams') {
                $scope.onSetSoftphoneParams (e.data.params);
        // call data was changed in operator console
            } else if (e.data.event == 'changeCallData') {
                $scope.onChangeCallData (e.data.params);
        // processing was finished in the operator console: close call from in Naumen to end the current call
            } else if (e.data.event == 'closeCall') {
                if ($scope.call != null) {
                    console.log('closing call..');
                    $scope.closeCall();
                }
                $scope.postMessage_callClosed();
            }
    // message events from this softphone        
        } else if (e.data.origin == 'NaumenDialer') {
            if (e.data.event == 'callCreated') {
                $scope.onCallCreated ();
            }
        }
    }
// ------- SET SOFTPHONE PARAMS -----------------------------------------
    $scope.onSetSoftphoneParams = function (params) {
        console.log('onSetSoftphoneParams ', params);
        $scope.saveCustomerCallInfo = params.saveCustomerCallInfo; // use this parameter if need to save call data in softphone controller (now it's set as false always since we only use softphone in ccspeedup page, where all the data is being saved)
    }
// ------- UPDATE CALL DATA -----------------------------------------
    $scope.onChangeCallData = function (params) {
        console.log('onChangeCallData ', params);
        if (params.extensionNumber != null) {
            $scope.call.customer.extensionNumber = params.extensionNumber;
        } 
    }
// ------- CHANGE SOFTPHONE MODES ----------------------------------------------
    $scope.toStartMode = function (updateUserState) {
        console.log('toStartMode : update state to normal : ' + updateUserState);
        $scope.softphoneMode = "START";
        if (updateUserState) {
            if ($scope.setBreak == null) {
                $scope.setUserState('normal');
            } else {
                $scope.setUserState($scope.setBreak.state, $scope.setBreak.reason);
                $scope.setBreak = null;
            }
        }
        if ($scope.$root.$$phase != '$apply') $scope.$apply();

        if ($scope.userState.state == 'wrapup') {
            console.warn('previous call was ended incorrect way');
            $scope.closeCurrentCall();
        }
    }
    $scope.toCallMode = function () {
        console.log('toCallMode');
        $scope.softphoneMode = "CALL";
        $scope.$apply();
    }
// -------------- USER STATUS METHODS ---------------------------------
    $scope.onClickSetUserState = function (state, reason) {
        var setState = true;
        if ($scope.userState.state == 'away' && $scope.userState.reason == null || $scope.userState.reason == '') { // call processing
            if ($scope.call != null) {
                if (state != 'normal') {
                    $scope.setBreak = {state: state, reason: reason};
                }
                setState = false;
            }
        }
        if (setState) $scope.NauPhone.setUserState(state, reason);
        $scope.openStatusesList();
    }
    $scope.openStatusesList = function () {
        if(document.getElementById('changeStatusDropdown').className.indexOf("slds-is-open") == -1) {
            document.getElementById('changeStatusDropdown').classList.add('slds-is-open');
        } else {
            document.getElementById('changeStatusDropdown').classList.remove("slds-is-open");
        }
    };
    $scope.setUserState = function (state, reason) {
        $scope.NauPhone.setUserState(state, reason); 
    }
// ------- CALL METHODS -----------------------------------------
// ---call modes------------------------------------------	
    $scope.toCallMode_Ringing = function () { // swtitch to 'RINGING' call mode
        console.log('SP: toCallMode_Ringing');
        console.log('call : ', $scope.call);
        $scope.call.stateMode = "RINGING";
        $scope.$apply();
        $scope.showSoftphone();
    }
    $scope.toCallMode_Talking = function () { // swtitch to 'TALKING' call mode
        console.log('SP: toCallMode_Talking');
        console.log('call : ', $scope.call);
        $scope.call.stateMode = "TALKING";
        $scope.countUp();
        $scope.$apply();
        $scope.showSoftphone();
    }
    $scope.toCallMode_Processing = function () { // swtitch to 'PROCESSING' call mode
        console.log('SP: toCallMode_Processing');
        console.log('call : ', $scope.call);
        $scope.setUserState('away');
        $scope.call.stateMode = "PROCESSING";
        $scope.saveTalkData();
        $scope.updateCallDataInConsole();
        var processingLimit = 3*60; // 3 min
        $scope.countUp(processingLimit);
        $scope.$apply();
    }
// ---call timer------------------------------------------	        
    $scope.timerUp;
    $scope.stopCounting = function () {
        clearInterval( $scope.timerUp);
        $scope.call.seconds = 0;
        $scope.call.timeOutput = '00:00'; // output value for softphone UI
        if ($scope.$root.$$phase != '$apply') $scope.$apply();
    }
    //------- count up -----------
    $scope.startCountUp = function (seconds) {
        $scope.call.seconds = seconds == null ? 0 : seconds;
        $scope.call.timeOutput = '00:00'; // output value for softphone UI
        $scope.countUp();
    }
    $scope.countUp = function (countLimit) {
        $scope.timerUp = setInterval(function() {
            if ($scope.call == null) {
                clearInterval( $scope.timerUp);
                return;
            }
            ++$scope.call.seconds;
            $scope.call.timeOutput = moment.utc($scope.call.seconds*1000).format('mm:ss'); // output value for softphone UI
            $scope.$apply();
            if ($scope.call.stateMode == "PROCESSING") { // limit time for processing call mode
                if (countLimit != null && $scope.call.seconds == countLimit) {
                    console.log('processing limit time is exceeded');
                    $scope.endCall(true);
                }
                // update call data to unlock save button in the operator console in case it hasn't been unlocked
                if ($scope.call != null) {
                    if ($scope.call.seconds == 3) { // update call data on the 3rd second of processing
                        $scope.updateCallDataInConsole();
                    } else if ($scope.call.seconds >= 10) {// update call data every 10 seconds of processing
                        var devide10Num = $scope.call.seconds/10;
                        if (Math.round(devide10Num) == devide10Num) {
                            $scope.updateCallDataInConsole();
                        }
                    }
                }
            }
           
        }, 1000);
    }
// ---call buttons actions------------------------------------------
    $scope.hangupCall = function () { // used on hanf up button - hang up the call, after what processing time is starting
        console.log('>>> in >>> hangupCall : call params : ', $scope.call.callParams);
        var params = {id: $scope.call.callParams.id};
        $scope.NauPhone.makeRequest('hangup', params);
    }
    $scope.closeCall = function (call) { // close Naumen call form (finishes processing the call)
        var callId = call == null ? $scope.call.callParams.id : call.id;
        console.log('>>> in >>> closeCall : callParam : ' + callId);
        var params = {id: callId};
        $scope.NauPhone.makeRequest('close', params);
    }
    $scope.closeCurrentCall = function () { // close current active call in the softphone
        $scope.NauPhone.getCurrentCall().then(function (curCall) {
            $scope.closeCall(curCall);
        });
    }
    $scope.answerCall = function () { // used on answer buttton - answer inbound call
        console.log('>>> in >>> answerCall : callId : ' + $scope.call.callParams.id);
        var params = {id: $scope.call.callParams.id};
        $scope.NauPhone.makeRequest('answer', params);
    }
    $scope.makeCall = function (callNumber) { // make an outbound call from softphone
        var params = {url: callNumber};
        $scope.NauPhone.makeRequest('makeCall', params);
    }
    $scope.makeImmediateCall = function () { // used on make call button when processing call time is started
        var immediateCallNumber = document.getElementById('immediateCallNumber').value;
        immediateCallNumber = immediateCallNumber.replace('#', '/pp');
        console.log('>>> in >>> makeImmediateCall : immediateCallNumber : ' + immediateCallNumber);
        $scope.immediateCallNumber = immediateCallNumber;
        $scope.saveRecordInConsole(); // if we start immediate call from softphone while processing the first call then save first call data in the console before starting the new call
    }
    $scope.makeOutboundCall = function () { // used on make call button on the start mode in softphone - when the operator is free
        var outboundCallNumber = document.getElementById('outboundCallNumber').value;
        outboundCallNumber = outboundCallNumber.replace('#', '/pp');
        console.log('>>> in >>> makeOutboundCall : outboundCallNumber : ' + outboundCallNumber);
        $scope.makeCall(outboundCallNumber);
    }
    $scope.transferCall = function () { // transfer call to another Naumen operator
        var transferNumber = document.getElementById('transferNumber').value;
        console.log('>>> in >>> transferCall : transferNumber : ' + transferNumber);
        var params = {id: $scope.call.callParams.id, number: transferNumber};
        $scope.NauPhone.makeRequest('consultationTransfer', params);
        $scope.call.transfered = true;
    }
    $scope.breakTransfer = function () { // cancel current transfering of the call to another operator
        console.log('>>> in >>> breakTransfer : callId : ' + $scope.call.callParams.id);
        var params = {id: $scope.call.callParams.id};
        $scope.NauPhone.makeRequest('breakTransfer', params);
        $scope.call.transfered = false;
    }

// ---get call params------------------------------------------  
    $scope.transferCallAvailable = true; // operator can press the button to transfer the call
    $scope.getRecordId = function () {  // get id of current customer of the call
        return ($scope.call != null && $scope.call.customer != null && $scope.call.customer.recordId != null) ? $scope.call.customer.recordId 
                                                                                                              : null;
    }
    $scope.getNaumenProjectUUID = function () { // get UUID of Project in Naumen for which current call case is being processed
        return $scope.call.callParams.params['ProjectId'];
    }
    $scope.getNaumenCaseUUID = function () { // get UUID of Naumen call case which initiated the current active call
        return $scope.call.callParams.params['npcp-dialer-client-ext-id'];
    }
    $scope.getPhoneNumber = function (callType, params) { // get phone number from Naumen call case params
        return callType == 'autocall' ? params['called'] 
             : callType == 'callback' ? params['called'] 
             : callType == 'inbound' ? params['caller']
             : callType == 'outbound' ? params['called'] 
             : null;
    }
    $scope.isInternalPhone = function (phoneNum) { // check if the phone number belongs another operator in Naumen
        // if there is no naumen case number in the params then it is an inbound call
        return phoneNum.length < 6;
    }
    $scope.getCallType = function (params, operatorName) { // get type of the current call
        return $scope.isCallback(params, operatorName) ? 'callback' // the call was initiated from a call case set on certain operator (not on all queue)
             : $scope.isNaumenAutocall(params) ? 'autocall' // the call was initiated from a call case which was set on all operators queue
             : $scope.isInternalCall(params) ? 'internal' // the call was initiated by another operator
             : $scope.isInboundCall(params) ? 'inbound' // the customer called back by the company's phone number
             : $scope.isOutboundCall(params) ? 'outbound' // the operator made a call to a customer manually from softphone
             : null;
    }
    $scope.getOperatorName = function (params) { // get operator name by call params (on this operator the call case was set) 
        var operatorName;
        var scriptParams = params.scriptParams;
        if (scriptParams != null) {
            var scriptParamsArr = scriptParams.split(' --');
            for (var i = 0; i<scriptParamsArr.length; i++) {
                var paramItem = scriptParamsArr[i];
                var paramItemSplitted = paramItem.split('=');
                var paramName = paramItemSplitted[0];
                var paramVal = paramItemSplitted[1];
                if (paramName == 'oper') {
                    operatorName = paramVal;
                    break;
                }
            }
        }
        return operatorName == null || operatorName.replace(/\s/g, '') == '' ? null : operatorName;
	}
    
    $scope.isCallback = function (params, operatorName) { // check by call params if the call was scheduled for the certain operator
        return $scope.isNaumenAutocall(params) && operatorName != null;
    }
    $scope.isNaumenAutocall = function (params) { // check by call params if the call was set on all operators queue
        // if there is no naumen case number in the params then it is an inbound call
        return params.direction == 'in' 
            && params['npcp-dialer-client-ext-id'] != null // there is a naumen case uuid
    }
    $scope.isInternalCall = function (params) { // check by call params if the call was initiated from another operator
        // if there is no naumen case number in the params then it is an inbound call
        return params.direction == 'in' && $scope.isInternalPhone(params.called);
    }
    $scope.isInboundCall = function (params) { // check if the call was initiated by a customer
        // if there is no naumen case number in the params then it is an inbound call
        return params.direction == 'in' && !params['npcp-dialer-client-ext-id'];
    }
    $scope.isOutboundCall = function (params) { // check if the call was initiated by operator
        // if there is no naumen case number in the params then it is an inbound call
        return params.direction == 'out';
    }
// ---create a new call------------------------------------------ 
    $scope.createNewCall = function (call) {
        console.log('>> in createNewCall >>');
        call.getParams().then(function (params) {$scope.setNewCallParams(params, call)});    
    }
    $scope.setNewCallParams = function (callParams, call) {
        console.log('>> in setNewCallParams >>', callParams);
/* blockedCalls are not being used now - we process all calls: inbound, outbound and autocalls
        // check if the call is an inbound call initied by the customer
        var callId = callParams.id;
        if($scope.dontProcessCall(callParams.params)) {
            $scope.blockedCalls[callId] = callParams;
            console.log('$scope.blockedCalls : ', $scope.blockedCalls);
            return; // dont process certain calls
        }
*/
        if ($scope.call == null) { // init new call if there is no active call now
            $scope.initCall (callParams, call);
            $scope.$apply();
        }
    }
    $scope.initCall = function (callParams, call) { // init the new call in softphone
        console.log('>>> in >>> initCall : current call : ', $scope.call);
        $scope.call = {};
        $scope.setCallParams(callParams);
        $scope.call.seconds = 0;
        $scope.call.talkDuration = 0;
        $scope.call.processingDuration = 0; 
        
        if ($scope.immediateCallNumber != null) {
            $scope.call.previousCall = Object.assign({}, $scope.previousCall);
            $scope.previousCall = null;
            $scope.immediateCallNumber = null;
        }
        $scope.toCallMode();
        call.getState().then($scope.updateCallState);
    }
    $scope.setCallParams = function (callParams) {
        $scope.call.callParams = callParams;
        $scope.call.operatorName = $scope.getOperatorName(callParams.params);
        $scope.call.type = $scope.getCallType(callParams.params, $scope.call.operatorName);
        $scope.call.phoneNumber = $scope.getPhoneNumber($scope.call.type, callParams.params);
        $scope.call.processingTimeNeeded = $scope.call.type != 'internal'; 
    }
    $scope.onCallCreated = function () {
        // if the created call is the immedaite call initiated by operator then update call data in the operator console
        if ($scope.call.previousCall != null) { // the call which was created now is the second call initiated by operator (immediate call)
            $scope.call.customer = $scope.call.previousCall.customer;
            $scope.$apply();
            $scope.updateCallDataInConsole();
        // if the created call is a new call then update call data in sotphone and operator cosnole
        } else if ($scope.call.type == 'autocall' || $scope.call.type == 'callback') { // for now we only look for a record if it is a Naumen autocall
            $scope.getRecord ($scope.getNaumenCaseUUID(), $scope.call.phoneNumber);
        }
    }
/* blockedCalls are not being used now - we process all calls: inbound, outbound and autocalls
    $scope.dontProcessCall = function (params) {
        // if the call came not from a Naumen Case then don't process this call (for now only process autocalls coming from predictive dialing in Naumen)
        if (params.direction == 'in') { // an inbound call (Naumen autocall or inbound call from the customer)
            return false;
        } else {
            return false;
            //return true; // don't process outbound calls for now
        }
        return false; // this call will be processed (outbound call or autocall form a Naumen Case)
    } 
*/
// ---end call------------------------------------------ 
    $scope.endCall = function (toStartMode) { // end current active call
        console.log('>> in endCall >>',  $scope.call);
        if ($scope.immediateCallNumber == null) $scope.postMessage_closeRecord(); // close record in console if there is no immediate call in progress
        if ($scope.call.stateMode == "TALKING") {
            $scope.saveTalkData();
        } else if ($scope.call.stateMode == "PROCESSING") {
            $scope.saveProcessingData();
        }
        $scope.previousCall = $scope.call == null ? null : Object.assign({}, $scope.call); // save current call data
        $scope.closeCall(); // close Naumen call form
        $scope.clearCallData(); // clear current call data
        if (toStartMode == true) $scope.toStartMode(true); // make operator free for the call (or set break if needed)
    }
    $scope.clearCallData = function () {
        $scope.call = null;
        $scope.clearInputs();
    }
    $scope.clearInputs = function () {
        document.getElementById('outboundCallNumber').value = '';
        document.getElementById('transferNumber').value = '';
        document.getElementById('immediateCallNumber').value = '';
    }
// ---update call data------------------------------------------
    $scope.updateCallState = function (callState) {
        console.log('>> in updateCallState >>', callState);
        if ($scope.call == null) return; 
        var callId = callState.id;
        //if ($scope.blockedCalls[callId] == undefined) { // blockedCalls are not being used now - we process all calls: inbound, outbound and autocalls
            var isNewCall = $scope.call.callState == null;
            if (isNewCall || (callId == $scope.call.callParams.id && $scope.call.callState.state != callState.state)) {
                if ($scope.softphoneMode == "CALL") {
                    console.log('update call state in softphone...');
                // operator is not connected with the customer yet
                    if (callState.state == 'new') {
                        $scope.toCallMode_Ringing();
                // operator is connected with the customer
                    } else if (callState.state == 'connected') {
                        $scope.toCallMode_Talking();
                // operator was connected with the customer and the call is ended now
                    } else if (callState.state == 'ended' && $scope.call != null && $scope.call.callState != null && $scope.call.callState.state == 'connected') {
                        if($scope.call.customer != null && $scope.call.recordSaved == true) { 
                        // record was already saved, we may finish the call
                            $scope.endCall(true);
                            return;
                        } else {
                            if ($scope.call.processingTimeNeeded) $scope.toCallMode_Processing();
                            else $scope.endCall(true);
                        }
                // didn't have time to set the call's params when the call was already ended
                    } else if (callState.state == 'ended' && isNewCall) { 
                        if ($scope.call.processingTimeNeeded) $scope.toCallMode_Processing();
                        else $scope.endCall(true);

                // operator wasn't connected with the customer and the call is ended
                    } else if (callState.state == 'ended' && $scope.call.callState.state == 'new') {
                        if ($scope.call.processingTimeNeeded) $scope.toCallMode_Processing();
                        else $scope.endCall(true);
                    }
                    if ($scope.call != null) $scope.call.callState = callState;
                    $scope.$apply();
                    if (isNewCall) $scope.postMessage_callCreated(); // push event that new call is created
                }
            }
/* blockedCalls are not being used now - we process all calls: inbound, outbound and autocalls
        } else {
            console.log('dont update this call : ' + callId); 
        }
*/
    }
// ---save call data in sf------------------------------------------
    $scope.saveTalkData = function () {
        $scope.call.talkDuration =  $scope.call.seconds;
        $scope.stopCounting();
    }
    $scope.saveProcessingData = function () {
        $scope.call.processingDuration = $scope.call.seconds;
        $scope.stopCounting();
    }

// ------- WORKING WITH CUSTOMER RECORD IN OPERATOR CONSOLE ----------------------------------------------
// --- push events for the operator console ---
    $scope.openRecordInConsole = function () { // open current customer record in the operator console
        $scope.postMessage_openRecord();       
    }
    $scope.updateCallDataInConsole = function () { // update call data in the operator console if needed
        console.log('>> in >> updateCallDataInConsole');
        $scope.postMessage_updateCallData();       
    }
    $scope.saveRecordInConsole = function () { // force console to save current call data so we can start the new call for the current customer
        $scope.postMessage_saveRecord();     
    }
// --- process events from the operator console ---
    $scope.onCallCustomerFound = function (callCustomerId) { // call customer was found/created in the operator console
        console.log('>>>onCallCustomerFound>>> callCustomerId : ' + callCustomerId);
        if ($scope.call != null && callCustomerId != null && callCustomerId != '') $scope.setCallCustomer(callCustomerId, $scope.call.phoneNumber);
    }

    $scope.onRecordSaved = function (recordId) { // record was saved in the operator console
        console.log('>>>onRecordSaved>>> recordId : ' + recordId);
        if ($scope.call != null) {
            $scope.call.recordSaved == true;
            var immediateCallIsInProgress = $scope.immediateCallNumber != null;
            if ($scope.call.callState.state == 'ended') {
                var setStateToNormal = immediateCallIsInProgress ? false : true;
                $scope.endCall(setStateToNormal);
            }
            if (immediateCallIsInProgress) {
                $scope.makeCall($scope.immediateCallNumber);
            }
        }
    }
// ------- WORKING WITH CUSTOMER RECORD IN SOFTPHONE ----------------------------------------------
    $scope.showRecordInSoftphone = function (callCustomer) { // show call customer info in the softphone
        console.log('>>showRecordInSoftphone >> ', callCustomer);
        $scope.call.customer = callCustomer;
        $scope.$apply();
    }
    $scope.setCallContact = function (callContact) { // for opportunities: show related contact info in the softphone
        console.log('>>setCallContact >> ', callContact);
        $scope.call.customer.callCustomerId = callContact.recordId;
        $scope.call.customer.allContacts[callContact.recordId] = callContact;
        $scope.$apply();
    }
    $scope.closeRecordInSoftphone = function () { // close call customer info in the softphone
        console.log('>>closeRecordInSoftphone >> ');
        $scope.endCall(true); // closes Naumen Form
    }
    /* not used now
    $scope.openNaumenForm = function () { // open Naumen form set for the current project
        window.open($scope.call.callParams.params.url, $label_Naumen_OpenNaumenForm, 'height=400,width=645');
    }
    */
// ----- UTILITY BAR FUNCTIONS -----
    $scope.hideSoftphone = function () { // hide softphone panel
        document.getElementById('Softphone').style.display = 'none';
        document.getElementById('UtilityBar').style.display = 'block';
    }
    $scope.showSoftphone = function () { // show softphone panel
        document.getElementById('Softphone').style.display = 'block';
        document.getElementById('UtilityBar').style.display = 'none';
    }

// ----- MODAL POPUPS FUNCTIONS -----
    $scope.showNotification = function (msgType, msgHeader, msgText) { // show pop up notification to the operator
        console.log('>> notification >> ' + msgType + ' : ' + msgHeader + ' : ' + msgText);
        document.getElementById('overlay').style.display = 'block'; 
        $scope.notification = {};
        $scope.notification.type = msgType;
        $scope.notification.headerText = msgHeader;
        $scope.notification.bodyText = msgText;
        $scope.$apply();
    }
    $scope.closeModal = function () { // close popup notification
        document.getElementById('overlay').style.display = 'none';
        $scope.notification = null;
    }
//-------- CONTROLLER REMOTE FUNCTIONS --------------
    // look for the customer record by phone number and naumen case UUID
    $scope.getRecord = function (recordUUID, phoneNumber) {
        console.log('>>> in >>> getRecord : recordUUID : ' + recordUUID + ' phoneNumber : ' + phoneNumber);
        Visualforce.remoting.Manager.invokeAction(
            'Naumen_SoftphoneController.getRecord',
            recordUUID, phoneNumber,
            function(result, event){
                result = JSON.stringify(result).replace(/&quot;/g, '\\"');
                result = JSON.parse(result);
            console.log('result : ', result);
            console.log('event : ', event);
                if (event.status) {
                    if (result.status == 'ok') {
                        $scope.showRecordInSoftphone(result.record);
                        if ($scope.call && $scope.call.customer) {
                            $scope.openRecordInConsole(); // customer is found, open customer in the operator console
                        }
                    } else {
                        var errHeader = $label_Naumen_notifHeader_RecordWasntFound;
                        var errMsg = result.message + ' [RecordUUID : ' + recordUUID + '.  PhoneNumber : ' + phoneNumber + '] ';
                        $scope.showNotification ('warning', errHeader, errMsg); // show notification to user
                    }
                } else if (event.type === 'exception') {
                    var errHeader = $label_Naumen_notifHeader_RecordWasntFound;
                    var errMsg = event.message + "; " + event.where + ' [recordUUID : ' + recordUUID + '.  phoneNumber : ' + phoneNumber +  '] ';
                    $scope.processGetRecordError(errHeader, errMsg);
                } else {
                    var errHeader = $label_Naumen_notifHeader_UnknownError;
                    var errMsg = event.message;
                    $scope.processGetRecordError(errHeader, errMsg);
                }
            }, 
            {escape: true}
        );
    }
    $scope.processGetRecordError = function (errHeader, errMsg) {
        $scope.hangupCall();// prevent call if error occured while getting the record in salesforce
        $scope.showNotification ('error', errHeader, errMsg); // show notification to user
    }  
    // set call customer which was found/created in the operator console
    $scope.setCallCustomer = function (callCustomerId, phoneNumber) {
        console.log('>>> in >>> setCallCustomer : callCustomerId : ' + callCustomerId + ' phoneNumber : ' + phoneNumber);
        Visualforce.remoting.Manager.invokeAction(
            'Naumen_SoftphoneController.setCallCustomer',
            callCustomerId, phoneNumber,
            function(result, event){
            console.log('result : ', result);
            console.log('event : ', event);
                if (event.status) {
                    if (result.status == 'ok') {
                        $scope.showRecordInSoftphone(result.callCustomer); // show call customer info int he softphone
                    }
                }
            }, 
            {escape: true}
        );
    }
/* not used now since we use naumen softphone on ccspeedup page only
                        //var callDataToSave = {"recordId":$scope.getRecordId(), "phoneNumber":$scope.call.phoneNumber};
                        //$scope.saveCallData(callDataToSave);

    $scope.saveCallData = function (callDataToSave) {
        console.log('>>> in >>> saveCallData ', callDataToSave);
        Visualforce.remoting.Manager.invokeAction(
            'Naumen_SoftphoneController.saveCallData',
            JSON.stringify(callDataToSave),
            function(result, event){
                console.log('result : ', result);
                console.log('event : ', event);
                if ($scope.call.callState.state == 'ended') { // call was already hang up before operator saved the record
                    $scope.endCall(true);
                } else {
                    $scope.call.recordSaved = true;
                }
                if (event.status) {
                    if (result.status == 'ok') {
                        console.log('data was succesfully saved!');
                    } else {
                        $scope.showNotification ('error', $label_Naumen_notifHeader_RecordWasntSaved, $label_Naumen_notifMsg_UnableToUpdatePhoneInfo + ' ' + result.message);
                    }
                } else if (event.type === 'exception') {
                    $scope.showNotification ('error', $label_Naumen_notifHeader_RecordWasntSaved, event.message + "; " + event.where);
                } else {
                    $scope.showNotification ('error', $label_Naumen_notifHeader_UnknownError, event.message);
                }
            }, 
            {escape: true}
        );
       
    }
     */
});