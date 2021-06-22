({
    // SYSTEM EVENTS HANDLERS

    init : function(component, event, helper) {
        // Global data for Team Status tab
        window._agentsMap = new Map();
        window._teamsSet = new Set();

        window._callbackList = new Array();

        // Disable status selection for startup states
        var item = component.find("statAvailableSpan");
        $A.util.addClass(item, 'inactive');
        item = component.find("statBusySpan");
        $A.util.addClass(item, 'inactive');
        item = component.find("statAwaySpan");
        $A.util.addClass(item, 'inactive');

        helper.addEventListeners();

    },


    afterSocketIOLoaded: function(cmp, event, helper) {
        //console.log('SocketIO Loaded.');
        helper.addLogRecord('DBG', 'RESULT', '{}', 'SocketIO Loaded.', cmp);

        var getAgentSetup = cmp.get("c.getAgentSetup");
        
        getAgentSetup.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storedResponse = response.getReturnValue();

                var id = storedResponse['AgentId'];
                var ext = storedResponse['Extension'];
                var url = storedResponse['URL'];
                var uname = storedResponse['Username'];

                cmp.set("v.ShowLog", storedResponse['ShowLogs']);
                cmp.set("v.SaveLog", storedResponse['SaveLogs']);

                //console.log('Salesforce Username: ' + uname + ' AgentID: ' + id + ' Extension: ' + ext);
                helper.addLogRecord('DBG', 'RESULT', '{}', 'Salesforce Username: ' + uname + ' AgentID: ' + id + ' Extension: ' + ext, cmp );

                cmp.set("v.agentInfo", "Agent: "+id+"  Extension: "+ext);
                cmp.set("v.agentId", id);

                window._agentid = id;
                window._extension = ext;

                helper.registerHandlers(url, uname, cmp);
                
            }else{
                //console.log('getAgentSetup(): Error reading User', response.getError());
                helper.addLogRecord('DBG', 'ERROR', '{}', 'getAgentSetup(): Error reading User - '+ response.getError(), cmp );
            }
        });
        $A.enqueueAction(getAgentSetup);
        
    },


    afterOpenCTILoaded: function(cmp, event, helper) {
        //console.log('OpenCTI Loaded.');
        helper.addLogRecord('DBG', 'RESULT', '{}', 'OpenCTI Loaded.', cmp);

        // Open phone panel for active call states
        if(window.localStorage.getItem('_callState') == "Ringing" || window.localStorage.getItem('_callState') == "Talking" || window.localStorage.getItem('_callState') == "Consulting" || window.localStorage.getItem('_callState') == "Holding"){
            sforce.opencti.isSoftphonePanelVisible({ callback: helper.isPanelVisibleCallback });
        }
        
    },


    // Process Call Center events
    handleCTIEvent: function(cmp, event, helper){
        var eventData = event.getParam("eventData");
        //console.log('Component received: ' + eventData.event, JSON.parse(JSON.stringify(eventData.data)));

        var controlState = Object();

        
        // Process network connect
        if( eventData.event == "connect" ){
            var agentState = Object();

            agentState.icon = "STATUS_ICON_OFFLINE";
            agentState.state = "Online";
            agentState.agentStatus = "0";
            agentState.manualChange = false;
            agentState.loginState = false;
            agentState.connected = true;

            helper.updateAgentState(cmp, agentState);

            // STCP1-1219 Disable Consult and Transfer buttons
            helper.toggleConsultButton(cmp, false);
            helper.toggleRetrieveButton(cmp, false);
            helper.toggleTransferButton(cmp, false);
            
        }

        // Process network disconnect
        if( eventData.event == "disconnect" ){
            var agentState = Object();

            agentState.state = "Offline";
            agentState.agentStatus = "0";
            agentState.manualChange = false;
            agentState.icon = "STATUS_ICON_OFFLINE";
            agentState.loginState = false;
            agentState.connected = false;

            helper.updateAgentState(cmp, agentState);
            
            // STCP1-1219 Disable Consult and Transfer buttons
            helper.toggleConsultButton(cmp, false);
            helper.toggleRetrieveButton(cmp, false);
            helper.toggleTransferButton(cmp, false);

        }

        // Process network error
        if( eventData.event == "error" ){
            var agentState = Object();

            agentState.state = "Error";
            agentState.agentStatus = "0";
            agentState.manualChange = false;
            agentState.icon = "STATUS_ICON_OFFLINE";
            agentState.loginState = false;
            agentState.connected = false;

            helper.updateAgentState(cmp, agentState);
            
            // STCP1-1219 Disable Consult and Transfer buttons
            helper.toggleConsultButton(cmp, false);
            helper.toggleRetrieveButton(cmp, false);
            helper.toggleTransferButton(cmp, false);

        }


        // Process agent status update
        if(eventData.event == "agentStatusUpdate"){
            //console.log('STATUS', JSON.parse(JSON.stringify(eventData.data)));
            
            if( eventData.data.status == 0 ){
                var agentState = Object();

                agentState.state = "Unknown";
                agentState.agentStatus = "0";
                agentState.manualChange = false;
                agentState.icon = "STATUS_ICON_OFFLINE";
                agentState.loginState = false;
                agentState.connected = true;
                helper.updateAgentState(cmp, agentState);
                
                helper.toggleAnswerCallButton(cmp, false);
                helper.toggleHoldButton(cmp, false);
                helper.toggleHangupButton(cmp, false);
                helper.toggleDialPad(cmp, false);

                helper.toggleConsultButton(cmp, false);
                helper.toggleRetrieveButton(cmp, false);
                helper.toggleTransferButton(cmp, false);
                helper.toggleConsultingSection(cmp, false);
            }

            if(eventData.data.status == 1){
                var agentState = Object();

                agentState.state = "Available";
                agentState.agentStatus = "1";
                agentState.manualChange = true;
                agentState.icon = "STATUS_ICON_AVAILABLE";
                agentState.loginState = true;
                agentState.connected = true;
                helper.updateAgentState(cmp, agentState);

                helper.toggleAnswerCallButton(cmp, false);
                helper.toggleHoldButton(cmp, false);
                helper.toggleHangupButton(cmp, false);
                helper.toggleDialPad(cmp, true);

                helper.toggleConsultButton(cmp, false);
                helper.toggleRetrieveButton(cmp, false);
                helper.toggleTransferButton(cmp, false);
                helper.toggleConsultingSection(cmp, false);

                helper.updateC2DState(cmp, true);
                helper.clearCallerInfo(cmp);
            }

            if(eventData.data.status == 2){
                var agentState = Object();

                agentState.state = "Busy";
                agentState.agentStatus = "2";
                agentState.manualChange = true;
                agentState.icon = "STATUS_ICON_BUSY";
                agentState.loginState = true;
                agentState.connected = true;
                helper.updateAgentState(cmp, agentState);

                helper.toggleAnswerCallButton(cmp, false);
                helper.toggleHoldButton(cmp, false);
                helper.toggleHangupButton(cmp, false);
                helper.toggleDialPad(cmp, true);

                helper.toggleConsultButton(cmp, false);
                helper.toggleRetrieveButton(cmp, false);
                helper.toggleTransferButton(cmp, false);
                helper.toggleConsultingSection(cmp, false);

                helper.updateC2DState(cmp, true);
                helper.clearCallerInfo(cmp);

            }

            if(eventData.data.status == 3){
                var agentState = Object();

                agentState.state = "Away";
                agentState.agentStatus = "3";
                agentState.manualChange = true;
                agentState.icon = "STATUS_ICON_AWAY";
                agentState.loginState = true;
                agentState.connected = true;
                helper.updateAgentState(cmp, agentState);

                helper.toggleAnswerCallButton(cmp, false);
                helper.toggleHoldButton(cmp, false);
                helper.toggleHangupButton(cmp, false);
                helper.toggleDialPad(cmp, false);

                helper.toggleConsultButton(cmp, false);
                helper.toggleRetrieveButton(cmp, false);
                helper.toggleTransferButton(cmp, false);
                helper.toggleConsultingSection(cmp, false);

                helper.updateC2DState(cmp, false);
                helper.clearCallerInfo(cmp);
            }

            if(eventData.data.status == 4){
                var agentState = Object();

                //STCP1-1036 Process diverted call for Transfer
                if(eventData.data.handlingstate == 3){ // Ringing
                    if(eventData.data.currentcall.action == 'diverted'){
                        if(eventData.data.currentcall.extension == window._extension){
                            window.localStorage.setItem('_pendingCallID', eventData.data.currentcall.callid);
                            helper.toggleAnswerCallButton(cmp, true, "Answer");
                            cmp.set("v.currentTab", "callingTabDataId");
                            
                            // STCP-1247 Show alert if app is minimized during incoming call
                            if(helper.isMinimized()){
                                helper.popUpCallingTab();
                            }

                            // STCP1-1247 Open phone window
                            sforce.opencti.setSoftphonePanelVisibility({visible: true, callback: helper.callback});

                            // Switch to Calling tab
                            cmp.set("v.currentTab", "callingTabDataId");
                        }
                    }
                }
                
                if(eventData.data.handlingstate == 4){ // Talking
                    agentState.state = "Active";
                    agentState.agentStatus = "4";
                    agentState.manualChange = false;
                    agentState.icon = "STATUS_ICON_ONCALL";
                    agentState.loginState = true;
                    agentState.connected = true;

                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, true, "Hold");
                    helper.toggleHangupButton(cmp, true);
                    helper.toggleDialPad(cmp, false);

                    // Enalbe Consult and Transfer buttons only for certain call states
                    if(helper.getConsultEnabled() == "true"){
                        helper.toggleConsultButton(cmp, true);
                        helper.toggleRetrieveButton(cmp, false);
                        helper.toggleTransferButton(cmp, true);
                    }else{
                        helper.toggleConsultButton(cmp, false);
                        helper.toggleRetrieveButton(cmp, false);
                        helper.toggleTransferButton(cmp, false);
                    }

                }else if(eventData.data.handlingstate == 6){ // Holding
                    agentState.state = "Active";
                    agentState.agentStatus = "4";
                    agentState.manualChange = false;
                    agentState.icon = "STATUS_ICON_ONCALL";
                    agentState.loginState = true;
                    agentState.connected = true;

                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, true, "UnHold");
                    helper.toggleHangupButton(cmp, true);
                    helper.toggleDialPad(cmp, false);

                    helper.toggleConsultButton(cmp, false);
                    helper.toggleRetrieveButton(cmp, false);
                    helper.toggleTransferButton(cmp, false);

                }else if(eventData.data.handlingstate == 7){ // Consulting
                    agentState.state = "Active";
                    agentState.agentStatus = "4";
                    agentState.manualChange = false;
                    agentState.icon = "STATUS_ICON_ONCALL";
                    agentState.loginState = true;
                    agentState.connected = true;

                    helper.toggleConsultButton(cmp, false);
                    helper.toggleRetrieveButton(cmp, true);
                    if(window.localStorage.getItem('_consultPartyState' != "disconnected")){
                        helper.toggleTransferButton(cmp, true);
                    }

                }else if(eventData.data.handlingstate == 9){ // Processing
                    agentState.state = "Processing";
                    agentState.agentStatus = "5";
                    agentState.manualChange = false;
                    agentState.icon = "STATUS_ICON_AFTERCALL";
                    agentState.loginState = true;
                    agentState.connected = true;

                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, false);
                    helper.toggleHangupButton(cmp, false);
                    helper.toggleDialPad(cmp, false);

                    helper.toggleConsultButton(cmp, false);
                    helper.toggleRetrieveButton(cmp, false);
                    helper.toggleTransferButton(cmp, false);

                }else if(eventData.data.handlingstate == 10){ // PostProcessing
                    agentState.state = "After Call";
                    agentState.agentStatus = "5";
                    agentState.manualChange = true;
                    agentState.icon = "STATUS_ICON_AFTERCALL";
                    agentState.loginState = true;
                    agentState.connected = true;

                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, false);
                    helper.toggleHangupButton(cmp, false);
                    helper.toggleDialPad(cmp, false);

                    helper.toggleConsultButton(cmp, false);
                    helper.toggleRetrieveButton(cmp, false);
                    helper.toggleTransferButton(cmp, false);
                    helper.clearDialPadEx(cmp);
                    helper.clearConsultationInfo(cmp);

                }else{
                    agentState.state = "Active";
                    agentState.agentStatus = "4";
                    agentState.manualChange = false;
                    agentState.icon = "STATUS_ICON_ONCALL";
                    agentState.loginState = true;
                    agentState.connected = true;

                    helper.toggleConsultButton(cmp, false);
                    helper.toggleRetrieveButton(cmp, false);
                    helper.toggleTransferButton(cmp, false);
                }

                helper.updateAgentState(cmp, agentState);
            }


            if(eventData.data.status == 5){
                var agentState = Object();

                agentState.state = "Logged Off";
                agentState.agentStatus = "6";
                agentState.manualChange = false;
                agentState.icon = "STATUS_ICON_OFFLINE";
                agentState.loginState = false;
                agentState.connected = true;

                helper.updateC2DState(cmp, false);
                helper.updateAgentState(cmp, agentState);

                helper.clearCallerInfo(cmp);
            }

        }

        // Process assignevent
        if(eventData.event == "assignevent"){

            // STCP1-602 [CTI] "Phone" - pop-up when minimized
            // Show alert if app is minimized during incoming call
            if(helper.isMinimized()){
                helper.popUpCallingTab();
            }
            
            // Open phone window
            sforce.opencti.setSoftphonePanelVisibility({visible: true, callback: helper.callback});

            // Switch to Calling tab
            cmp.set("v.currentTab", "callingTabDataId");

            if(eventData.data.channel === 'callback') {
                // STCP1-1308 Search for callback phone number
                let callbackData = JSON.parse(JSON.stringify(eventData.data));
                helper.getCustomerInfoByPhone(cmp, callbackData.ani);

                // Set phone number from callback data
                cmp.set("v.phone", callbackData.ani);
                helper.toggleAnswerCallButton(cmp, true, "Accept");
            }
            else {
                helper.getCustomerInfoByPhone(cmp, eventData.data);

                // Set phone number
                cmp.set("v.phone", eventData.data);
                helper.toggleAnswerCallButton(cmp, true, "Answer");
            }

            helper.toggleHoldButton(cmp, false);
            helper.toggleHangupButton(cmp, false);
            helper.toggleDialPad(cmp, false);
            
        }


        // Process infocall
        if(eventData.event == "infocall"){

            var callControlsState = Object();
            
            if(eventData.data.action == "originated"){
                //console.log('ORIGINATED CALL TYPE = '+helper.getOriginatedCallType(eventData.data));

                // Outgoing call originated
                if(helper.getOriginatedCallType(eventData.data) == "OUTGOING"){
                        
                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, false);
                    helper.toggleHangupButton(cmp, true);
                    helper.toggleDialPad(cmp, false);

                    // Open phone window
                    sforce.opencti.setSoftphonePanelVisibility({visible: true, callback: helper.callback});

                    // Switch to Calling tab
                    cmp.set("v.currentTab", "callingTabDataId");

                    // Expand Calling section
                    //helper.expandCallingSection(cmp, event, helper);
                    helper.getCustomerInfoByPhone(cmp, eventData.data.dnis);

                    cmp.set("v.phone", eventData.data.dnis);
                }

                // Incoming Internal call originated
                if (helper.getOriginatedCallType(eventData.data) == "INTERNAL"){
                    
                    helper.toggleAnswerCallButton(cmp, true, "Answer");
                    helper.toggleHoldButton(cmp, false);
                    helper.toggleHangupButton(cmp, true);
                    helper.toggleDialPad(cmp, false);

                    // Open phone window
                    sforce.opencti.setSoftphonePanelVisibility({visible: true, callback: helper.callback});

                    // Switch to Calling tab
                    cmp.set("v.currentTab", "callingTabDataId");

                    // Expand Calling section
                    //helper.expandCallingSection(cmp, event, helper);

                    cmp.set("v.phone", eventData.data.ani);
                }

                // Callback originated
                if(helper.getOriginatedCallType(eventData.data) == "CALLBACK"){
                        
                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, false);
                    helper.toggleHangupButton(cmp, true);
                    helper.toggleDialPad(cmp, false);

                    // Open phone window
                    sforce.opencti.setSoftphonePanelVisibility({visible: true, callback: helper.callback});

                    // Switch to Calling tab
                    cmp.set("v.currentTab", "callingTabDataId");

                    // Expand Calling section
                    //helper.expandCallingSection(cmp, event, helper);
                    helper.getCustomerInfoByPhone(cmp, eventData.data.dnis);

                    cmp.set("v.phone", eventData.data.dnis);

                }

                // Outgoing Consultation call originated
                if (helper.getOriginatedCallType(eventData.data) == "CONSULT_OUT"){
                    
                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, false);
                    helper.toggleHangupButton(cmp, false);
                    helper.toggleDialPad(cmp, false);

                }

                // Incoming Consultation call originated
                if (helper.getOriginatedCallType(eventData.data) == "CONSULT_IN"){

                    helper.toggleAnswerCallButton(cmp, true, "Answer");
                    helper.toggleHoldButton(cmp, false);
                    helper.toggleHangupButton(cmp, false);
                    helper.toggleDialPad(cmp, false);

                    // Open phone window
                    sforce.opencti.setSoftphonePanelVisibility({visible: true, callback: helper.callback});

                    // Switch to Calling tab
                    cmp.set("v.currentTab", "callingTabDataId");

                    // Expand Calling section
                    //helper.expandCallingSection(cmp, event, helper);

                    cmp.set("v.phone", eventData.data.fromparty);

                    // STCP1-602 [CTI] "Phone" - pop-up when minimized
                    // Show alert if app is minimized during consultation call
                    if(helper.isMinimized()){
                        var origin = helper.getUrlParameters('sfdcIframeOrigin');
                        window.open(origin+"/apex/UnifyCallNotification", "_blank");
                    }
                }
                

            }

            if(eventData.data.action == "established"){
                let establishedCount = cmp.get("v.establishedCount");
                establishedCount++;
                cmp.set("v.establishedCount", establishedCount);
                if(establishedCount == 1) {
                    // Call type = ContactType_RoutedVoice. Incoming routed external call.
                    if(eventData.data.typ == 1 && eventData.data.state == 15){
                        //STCP1-1245 Disable\enable call controls for certain agent
                        if(eventData.data.extension == window._agent.extension){
                            helper.toggleAnswerCallButton(cmp, false);
                            helper.toggleHoldButton(cmp, true, "Hold");
                            helper.toggleHangupButton(cmp, true);
                            helper.toggleDialPad(cmp, false);
                        } else {
                            helper.toggleAnswerCallButton(cmp, false);
                            helper.toggleHoldButton(cmp, false, "Hold");
                            helper.toggleHangupButton(cmp, false);
                            helper.toggleDialPad(cmp, false);
                        }

                    }
                }

                // Call type = ContactType_DirectOutgoingVoice. Outbound direct external call.
                if(eventData.data.typ == 3 && eventData.data.state == 15){

                    //STCP1-1245 Disable\enable call controls for certain agent
                    if(eventData.data.fromparty == window._agent.extension){
                        helper.toggleAnswerCallButton(cmp, false);
                        helper.toggleHoldButton(cmp, true, "Hold");
                        helper.toggleHangupButton(cmp, true);
                        helper.toggleDialPad(cmp, false);
                    } else {
                        helper.toggleAnswerCallButton(cmp, false);
                        helper.toggleHoldButton(cmp, false, "Hold");
                        helper.toggleHangupButton(cmp, false);
                        helper.toggleDialPad(cmp, false);
                    }

                }

                // Call type = ContactType_DirectInternalVoice. Internal call.
                if(eventData.data.typ == 4 && eventData.data.state == 15){

                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, true, "Hold");
                    helper.toggleHangupButton(cmp, true);
                    helper.toggleDialPad(cmp, false);

                }
                
                // Call type = RoutedCallback.
                if(eventData.data.typ == 5 && eventData.data.state == 15){

                    //STCP1-1245 Disable\enable call controls for certain agent
                    if(eventData.data.fromparty == window._agent.extension){
                        helper.toggleAnswerCallButton(cmp, false);
                        helper.toggleHoldButton(cmp, true, "Hold");
                        helper.toggleHangupButton(cmp, true);
                        helper.toggleDialPad(cmp, false);
                    } else {
                        helper.toggleAnswerCallButton(cmp, false);
                        helper.toggleHoldButton(cmp, false, "Hold");
                        helper.toggleHangupButton(cmp, false);
                        helper.toggleDialPad(cmp, false);
                    }
                    
                }

                // Established Consult call
                if(eventData.data.state == 19){


                }

            }

            if(eventData.data.action == "disconnected"){

                if(eventData.data.extension == window.localStorage.getItem('_consultTarget')){ // Consult target disconnected
                    helper.toggleTransferButton(cmp, false);
                }else{
                    if(eventData.data.extension == eventData.data.ani){ // Customer party disconnected

                        //helper.toggleHangupButton(cmp,true);

                        helper.toggleConsultButton(cmp, false);
                        helper.toggleRetrieveButton(cmp, false);
                        helper.toggleTransferButton(cmp, false);

                    }
                }

                // STCP1-1172 Process unsuccessful callback
                let callbackInfo = helper.getCallbackInfo();
                if(callbackInfo != null && callbackInfo.switch){
                    cmp.set("v.currentTab", "callbackDataTabId");
                }
                
            }

            if(eventData.data.action == "diverted"){

                if(eventData.data.ani == window._agent.extension){

                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, true, "Hold");
                    helper.toggleHangupButton(cmp, true);
                    helper.toggleDialPad(cmp, false);

                }else{

                    helper.toggleAnswerCallButton(cmp, false);
                    helper.toggleHoldButton(cmp, false);
                    helper.toggleHangupButton(cmp, false);
                    helper.toggleDialPad(cmp, false);

                }
            }
        }


        // Process heldcall
        if(eventData.event == "heldcall"){

        }


        // Process retrievedcall
        if(eventData.event == "retrievedcall"){

        }


        // Process ClickToDial event. Generate call if phone number was clicked
        if(eventData.event == "ClickToDial"){

            // Place call only if Active
            let curentAgentStatus = cmp.get("v.agentStatus");
            if(curentAgentStatus == "1" || curentAgentStatus == "2"){
            
                var payload = eventData.data;

                // Open phone window
                sforce.opencti.setSoftphonePanelVisibility({visible: true, callback: helper.callback});
                cmp.set("v.currentTab", "callingTabDataId");

                // Expand Calling section
                //helper.expandCallingSection(cmp, event, helper);
                
                // Remove leading + from number
                var number = helper.formatPhoneNumber(payload.number);

                //console.log('ClickToDial: ' + number +' '+ payload.objectType +' '+ payload.recordId +' '+ payload.recordName );
                helper.addLogRecord('DBG', 'RESULT', '{}', 'ClickToDial: ' + number +' '+ payload.objectType +' '+ payload.recordId +' '+ payload.recordName, cmp );
                helper.getCustomerInfoByType(cmp, number, payload.objectType, payload.recordId);

                // Set phone number
                cmp.set("v.phone", number);
                cmp.set("v.outboundPhone", number);

                helper.toggleAnswerCallButton(cmp, true, "Call");
                helper.toggleHoldButton(cmp, false);
                helper.toggleHangupButton(cmp, true);
                helper.toggleDialPad(cmp, false);

                var phone = cmp.get("v.phone");
                helper.placeCall(phone);
            }
        }


        // Process callTaskCreated event. Open tab when call task is created
        if(eventData.event == "callTaskCreated"){
            var taskID = eventData.data;

            sforce.opencti.screenPop({
                type: sforce.opencti.SCREENPOP_TYPE.SOBJECT, 
                params: { recordId: taskID }
            });

        }

    },


    // LIGHTNING BUTTONs HANDLERS

    handleStatusSelect: function(cmp, event, helper){

        var selectedMenuItemValue = event.getParam("value");
        helper.setAgentStatus(selectedMenuItemValue);

    },


    handleStatusMenuSelect: function(cmp, event, helper){
        
        var sectionDiv = cmp.find("statusDropdown");
        var recId = event.currentTarget.id;
        
        if(recId == "statAvailableItem"){
            var span = cmp.find("statAvailableSpan");
            var isDisabled = $A.util.hasClass(span, "inactive");
            if(!isDisabled){
                helper.setAgentStatus(cmp, "1");
                $A.util.removeClass(sectionDiv, "slds-is-open");
                $A.util.addClass(sectionDiv, "slds-is-close");
            }
        }

        if(recId == "statBusyItem"){
            var span = cmp.find("statBusySpan");
            var isDisabled = $A.util.hasClass(span, "inactive");
            if(!isDisabled){
                helper.setAgentStatus(cmp, "2");
                $A.util.removeClass(sectionDiv, "slds-is-open");
                $A.util.addClass(sectionDiv, "slds-is-close");
            }
        }

        if(recId == "statAwayItem"){
            var span = cmp.find("statAwaySpan");
            var isDisabled = $A.util.hasClass(span, "inactive");
            if(!isDisabled){
                helper.setAgentStatus(cmp, "3");
                $A.util.removeClass(sectionDiv, "slds-is-open");
                $A.util.addClass(sectionDiv, "slds-is-close");
            }
        }
        
    },


    closeStatusDropdown: function(cmp, event, helper){


    },


    handleGetStatus:  function(cmp, event, helper){
        helper.getstatus();
    },

    // Dial pad buttons handlers - start

    handleCallAnswer: function(cmp, event, helper){
        var btn = cmp.find('answerCallButton');
        btn.set('v.disabled',true);
        
        if(btn.get("v.label") == "Answer"){
            helper.answerCall();
        }
        
        if(btn.get("v.label") == "Call"){
            var phone = cmp.get("v.outboundPhone");
            phone = helper.formatPhoneNumber(phone);
            
            // Set outbound call type Dial Pad or C2D
            //cmp.set("v.callType", "DialPadOutbound");
            window.localStorage.setItem('_callType', "DialPadOutbound");

            // Expand Calling section
            //helper.expandCallingSection(cmp, event, helper);

            // Search for matching Accounts and Contacts
            helper.getCustomerInfoByPhone(cmp, phone);

            helper.placeCall(phone);
        }

        if(btn.get("v.label") == "Accept"){
 
            let callBackDataJson = window.localStorage.getItem('_callBackData');
            let callBackData = JSON.parse(callBackDataJson);
            let callbackId = callBackData.callbackId;
            let extension = callBackData.extension;
            console.log('callBackData',callBackData);
            helper.acceptCallback(callbackId, extension);
        }

    },


    handlePhoneUpdate:  function(component, event, helper){
        component.set("v.callButtonDisabled", false);
        component.set("v.callButtonLabel", "Call");
        let extension = component.get("v.extension");
        if(extension == "") {
            component.set("v.callButtonDisabled", false);
        }

    },


    handleHangup: function(cmp, event, helper){
        cmp.find('hangupCallButton').set('v.disabled',true);
        helper.disconnectCall();
    },


    handleHold: function(cmp, event, helper){
        window.localStorage.setItem('_holdReason', "Button");

        var holdButton = cmp.find("holdCallButton");
        holdButton.set('v.disabled',true);
        var state = holdButton.get("v.label");
        
        if(state == "Hold"){
            helper.holdCall(1);
        }

        if(state == "UnHold"){
            helper.holdCall(0);
        }
        
    },

    // Dial pad buttons handlers - end

    // Team Status buttons handlers - start

    handleExtConsult: function(cmp, event, helper){
        window.localStorage.setItem('_transferType', "Consult");
        var ext = helper.formatPhoneNumber(cmp.get("v.extension"));
        helper.consultcall(ext);
    },


    handleExtRetrieve: function(cmp, event, helper){
        if(window.localStorage.getItem('_retrieveType') == "reconnectcall"){
            helper.reconnectcall();
        }

        if(window.localStorage.getItem('_retrieveType') == "unhold"){
            helper.retrievecall();
        }
    },


    handleExtTransfer: function(cmp, event, helper){

        if(window._agent.status == 4 && window._agent.handlingstate == 4){ // Talking
            var ext = helper.formatPhoneNumber(cmp.get("v.extension"));
            window.localStorage.setItem('_transferType', "Direct");
            helper.consultcall(ext);
        }

        if(window._agent.status == 4 && window._agent.handlingstate == 7){ // Consulting
            window.localStorage.setItem('_transferType', "Consult");
            helper.transfercall(window._agent.extension);
        }
        
    },


    handleAcceptCallback: function(cmp, event, helper){
        var cbid = cmp.get("v.callbackCallId");
        var ext = cmp.get("v.callbackExt");
        helper.acceptCallback(cbid, ext);
    },


    handleCompleteCallback: function(cmp, event, helper){
        var cbid = cmp.get("v.callbackCallId");
        var ext = cmp.get("v.callbackExt");
        var reason = cmp.get("v.callbackReason");
        helper.completeCallback(cbid, ext, reason);
    },


    handleUnCompleteCallback: function(cmp, event, helper){
        var cbid = cmp.get("v.callbackCallId");
        var ext = cmp.get("v.callbackExt");
        var reason = cmp.get("v.callbackReason");
        var interval = cmp.get("v.callbackInterval");
        helper.uncompleteCallback(cbid, ext, reason, interval);
    },


    handleListCallback: function(cmp, event, helper){
        console.log(window._callbackList);
    },


    handleIntervalSelect: function(cmp, event, helper){
        // let checkboxes = new Array(cmp.find("interval_none"));
        let checkboxes = new Array(cmp.find("interval_30"), cmp.find("interval_60"), cmp.find("interval_none"));
        let checkbox = event.getSource();
        let interval = checkbox.get("v.value");
        let checkedId = checkbox.getLocalId();
        let state = checkbox.get("v.checked");
        
        if(state){
            Object.keys(checkboxes).forEach(key => {
                let Id = checkboxes[key].getLocalId();
                if(checkedId !=Id ) {
                    //console.log('disable:'+Id);
                    cmp.find(Id).set("v.checked", false);
                }
            });

            if(helper.getCallbackInfo().state!='submitted'){
                cmp.find("submitCallbackButton").set("v.disabled", false);
            }
        } else {
            cmp.find("submitCallbackButton").set("v.disabled", true);
        }
        cmp.set("v.callbackInterval", interval);
    },


    handleIntervalSubmit: function(cmp, event, helper){
        let interval = cmp.get("v.callbackInterval");
        let callbackInfo = helper.getCallbackInfo();
        if(interval != 'none'){
            helper.uncompleteCallback(callbackInfo.callbackId, callbackInfo.extension, 21, interval);
        } else {
            helper.completeCallback(callbackInfo.callbackId, callbackInfo.extension, 2);
        }
        let checkboxes = new Array(cmp.find("interval_none"));
        Object.keys(checkboxes).forEach(key => {
            let Id = checkboxes[key].getLocalId();
            cmp.find(Id).set("v.checked", false);
        });
        cmp.set("v.currentTab", "callingTabDataId");
    },


    handleExtHangup: function(cmp, event, helper){
        helper.disconnectCall();
    },
    

    handleExtUpdate: function(cmp, event, helper){

        var input = event.getSource();

        if(input.get("v.value") == ""){ // No extension input
            // Disable buttons
            helper.toggleConsultButton(cmp, false);
            helper.toggleRetrieveButton(cmp, false);
            helper.toggleTransferButton(cmp, false);

            // Clear agent selection
            var availableCheckboxes = cmp.find('rowSelectionId');
            if (Array.isArray(availableCheckboxes)) {
                availableCheckboxes.forEach(function(checkbox) {
                    checkbox.set('v.checked', false);
                }); 
            } else {
                availableCheckboxes.set('v.checked', false);
            }
        }else{ // Extension provided

            if(window._agent.status == 4 && window._agent.handlingstate == 4){ // If Talking
                if(helper.getConsultEnabled() == "true"){
                    helper.toggleConsultButton(cmp, true);
                    helper.toggleRetrieveButton(cmp, false);
                    helper.toggleTransferButton(cmp, true);
                }else{
                    helper.toggleConsultButton(cmp, false);
                    helper.toggleRetrieveButton(cmp, false);
                    helper.toggleTransferButton(cmp, false);
                }


            } else if(window._agent.status == 4 && window._agent.handlingstate == 7){ // if Consulting
                helper.toggleConsultButton(cmp, false);
                helper.toggleRetrieveButton(cmp, true);
                helper.toggleTransferButton(cmp, true);
            } else {

                helper.toggleConsultButton(cmp, false);
                helper.toggleRetrieveButton(cmp, false);
                helper.toggleTransferButton(cmp, false);
            }

        }

        cmp.set("v.consultAgentName", "");
        cmp.set("v.selectedAgentId", "0");

    },


    handleAgentSelect: function(cmp, event, helper){
        var target = event.getSource();
        var agentId = target.get("v.value");
        var agent = window._agentsMap.get(agentId);

        var disabled = target.get("v.disabled");

        if(disabled == false){

            var availableCheckboxes = cmp.find('rowSelectionId');

            if (Array.isArray(availableCheckboxes)) {
                availableCheckboxes.forEach(function(checkbox) {
                    checkbox.set('v.checked', false);
                }); 
            } else {
                availableCheckboxes.set('v.checked', false);
            }
            
            target.set("v.checked",true);
            cmp.set("v.selectedAgentId", agentId);
            cmp.set("v.extension", agent.extension);
            cmp.set("v.consultAgentName", agent.firstname + ' ' + agent.lastname);

            helper.toggleConsultingSection(cmp, true);

            if(window._agent.status == 4 && window._agent.handlingstate == 4){
                if(helper.getConsultEnabled() == "true"){
                    helper.toggleConsultButton(cmp, true);
                    helper.toggleRetrieveButton(cmp, false);
                    helper.toggleTransferButton(cmp, true);
                }else{
                    helper.toggleConsultButton(cmp, false);
                    helper.toggleRetrieveButton(cmp, false);
                    helper.toggleTransferButton(cmp, false);
                }

            }

        }
	    
    },


    handleTeamSelect: function(cmp, event, helper){
        var select = event.getSource().get("v.value");
        cmp.set("v.selectedDepartmentName", select);
        window.localStorage.setItem('_selectedDepartmentName', select); 

    },

    
    // Team Status buttons handlers - end


    handleLogin: function(cmp, event, helper){
        helper.agentLogin();

    },


    handleLogout: function(cmp, event, helper){
        helper.agentLogout();

    },


    handlePower: function(cmp, event, helper){
        var state = cmp.get("v.state");
        var agentStatus = cmp.get("v.agentStatus");

        if(state != "Offline"){
            if(agentStatus == "6"){
                helper.agentLogin();
                //sforce.opencti.enableClickToDial({callback: helper.C2DCallback});
            }else{
                helper.agentLogout();
                //sforce.opencti.disableClickToDial({callback: helper.C2DCallback});
            }
        }
        
    },


    handleTest: function(cmp, event, helper){

        /*sforce.opencti.screenPop({
            type: sforce.opencti.SCREENPOP_TYPE.URL, 
            params: { url: '/apex/CTI_linkCallTask?phone=420266108430&callid=5768678563456' }
        });*/

        // Controller call to search for Accounts\Contacts\Tasks
        var phone = '420266108430'; // multiple accounts and contacts match. TODO: Select related account on contact select
        //var phone = '420775976197'; // multiple accounts and unique contact. TODO: Preselect related account
        //var phone = '4202661084307'; // Unique account and multiple contacts. TODO: Deselect contact
        var callid = '576867856343453453453';

        var action = window._comp.get("c.searchAccountAndContacts");
        action.setParams({
            phoneNumber: phone
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Search result, Accounts='+ result.Account.length+' Contacts='+result.Contact.length);

                if(result.Account.length > 1 || result.Contact.length > 1){
                    sforce.opencti.screenPop({
                        type: sforce.opencti.SCREENPOP_TYPE.URL, 
                        params: { url: '/apex/CTI_linkCallTask?phone='+phone+'&callid='+callid }
                    });
                }else{
                    var accId = null;
                    var conId = null;

                    if(result.Account.length == 1){
                        accId = result.Account[0].Id;
                    }

                    if(result.Contact.length == 1){
                        conId = result.Contact[0].Id;
                    }

                    //createNewTask(phone, callid, accId, conId);
                    var action = window._comp.get("c.createNewTask");
                        action.setParams({
                            phoneNumber: phone,
                            callID: callid,
                            AccountId: accId,
                            ContactId: conId
                        });

                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var taskId = response.getReturnValue();
                                window._callTaskID = taskId;
                                
                                // Fire callTaskCreated event
                                var eventData = { event: "callTaskCreated", data: taskId };
                                var compEvent = window._comp.getEvent("CTIinfoEvent");
                                compEvent.setParams({"eventData" : eventData });
                                compEvent.fire();
                                
                                console.log('Created Task ID', taskId);
                            }
                            else{
                                console.log('error', response.getError());
                            }
                        })
                        $A.enqueueAction(action);
                }
                
            }
            else{
                console.log('Search error', response.getError());
            }
        })
        $A.enqueueAction(action);
    },


    toggleSection: function(component, event){
        var auraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(auraId);

        var isClosed = $A.util.hasClass(sectionDiv, "slds-is-close");
        var isOpened = $A.util.hasClass(sectionDiv, "slds-is-open");
        
        if(isClosed) {
            $A.util.removeClass(sectionDiv, "slds-is-close");
            $A.util.addClass(sectionDiv, "slds-is-open");
        }

        if(isOpened) {
            $A.util.removeClass(sectionDiv, "slds-is-open");
            $A.util.addClass(sectionDiv, "slds-is-close");
        }

    },

    toggleOtherTeamSection: function(component, event){
        let isOtherTeamOpened = component.get("v.isOtherTeamOpened");
        component.set("v.isOtherTeamOpened", !isOtherTeamOpened);

    },


    showCallingTab: function(component, event) {
        component.set("v.currentTab", "callingTabDataId");
 
    },


    showTeamTab: function(component, event, helper) {
        component.set("v.currentTab", "teamTabDataId");
        helper.syncAgents();
    },


    showHistoryTab: function(component, event) {
        component.set("v.currentTab", "historyTabDataId");
    },


    showCallbackTab: function(component, event) {
        component.set("v.currentTab", "callbackDataTabId");
    },

    spam : function(component) {
        let state = '1';
        let i = 0;
        let tid = setInterval(()=>{
            if(state == '1'){
                state = '2';
            }
            else if(state == '2') {
                state = '1';
            }
            window._socket.emit('setagent', { key: window._agent.key, routing: state });
            i++;
        }, 55);
        setTimeout(() => { clearInterval(tid); alert('stop'); }, 20000);
    }


})