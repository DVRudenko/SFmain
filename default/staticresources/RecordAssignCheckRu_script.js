$j = jQuery.noConflict();

// ----------- params ----------------------
// --- regular expressions to check if the entered value is valid ---
var regs = {
    email: /^[a-zA-Zа-яА-Я0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Zа-яА-Я0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Zа-яА-Я0-9](?:[a-zA-Zа-яА-Я0-9-]*[a-zA-Zа-яА-Я0-9])?\.)+[a-zA-Zа-яА-Я0-9](?:[a-zA-Zа-яА-Я0-9-]*[a-zA-Zа-яА-Я0-9])?$/
  //, phone: /^((\+7|7|8)+([0-9]){10})$/
};

// --- data for processing calls on the page ---
var OperatorConsole;
var callData = {};

// ----------- document ready ----------------------
$j(document).ready(function () {
    initCTI ();
});
// ----------- functions ----------------------
function initCTI () {
    // init Naumen operator console
    try {
        OperatorConsole = initOperatorConsole (CURRENT_PAGE_URL);
    } catch (ex) {console.warn(ex);}
    // define parameters for Naumen operator console
    if (OperatorConsole != null) {
        OperatorConsole.setSoftphoneParameters(false);
        OperatorConsole.openRecordInConsole = function (recordId, callCustomerId, phoneNumber, extensionNumber, naumenProjectUUID, naumenCaseUUID, operatorName, callMode) {
            console.log('recordassign : ' + recordId + ' naumenProjectUUID : ' +  naumenProjectUUID + ' naumenCaseUUID : ' +  naumenCaseUUID + ' callMode : ' +  callMode);
            phoneNumber = phoneNumber.startsWith('8') ?phoneNumber.replace('8', '+7') : phoneNumber;
            openRecord(recordId, callCustomerId, phoneNumber, extensionNumber, naumenProjectUUID, naumenCaseUUID, operatorName, callMode);
        };
        OperatorConsole.updateCallDataInConsole = function (phoneNumber, extensionNumber, callMode) {
            updateCallData(phoneNumber, extensionNumber, callMode);
        }
        OperatorConsole.closeRecordInConsole = function () {closeRecord();};
        OperatorConsole.saveRecordInConsole = function () {
            saveCurrentCallData();
        }
        OperatorConsole.isTransferCallAvailable = isTransferCallAvailable;
    }
}
function setupPage(){
    console.log('>> in >> setupPage');
    changeKeyParameters(); 
    $j('.input-Pot_Litri').inputmask({mask:"999999999", "placeholder": "" }); //using jqueryInputMask.resource
    $j('.input-Pot_Rub').inputmask({mask:"999999999", "placeholder": "" });
    $j('.input-Pot_leg').inputmask({mask:"999999999", "placeholder": "" });
    $j('.input-Pot_gruz').inputmask({mask:"999999999", "placeholder": "" });
    //$j('.input-Phone').inputmask({mask:["89999999999","+99999999999"], "placeholder": "", keepStatic : false });
    //$j('.input-Phone2').inputmask({mask:["89999999999","+99999999999"], "placeholder": "", keepStatic : false });
    $j('.input-ExtensionNumber').inputmask({mask:"99999", "placeholder": "" });
    //$j('.input-Minute').inputmask('numeric', {min:0, max:59, mask:"99"});
    //$j('.input-Hour').inputmask('numeric', {min:0, max:23, mask:"99"});
    $j(".input-Hour").inputmask('integer',{min:1, max:23});
    $j(".input-Minute").inputmask({
        mask: "59",
        definitions: {
            '5': {validator: "[0-5]"}
        }
    });
    setPhoneField();
    processCallMode ();
    showSaveButton(true);
}
function onChangeInputPhoneField (elem) {
    defineNumberMask (elem, true); // use defineNumberMask from PD Forms JS
    if ($j(elem).hasClass('input-Phone')) $j('#callPhoneNumber').text($j(elem).val());
    if ($j(elem).hasClass('input-Phone2')) onChangeResultType();
}

function openRecord (recordId, callCustomerId, phoneNumber, extensionNumber, naumenProjectUUID, naumenCaseUUID, operatorName, callMode) {
    document.getElementById('RecordAssignCheckRu:pdRecordForm:inputTextRecordId').value = recordId;
    document.getElementById('RecordAssignCheckRu:pdRecordForm:inputCallCustomerId').value = callCustomerId;
    callData.callPhoneNumber = phoneNumber.length == 10 ? '+7'+phoneNumber : phoneNumber; 
    callData.callExtensionNumber = extensionNumber == null || extensionNumber == '' || extensionNumber == 'undefined' ? null : extensionNumber;
    callData.callMode = callMode; // may be = null or "PROCESSING"
    callData.naumenProjectUUID = naumenProjectUUID;
    callData.naumenCaseUUID = naumenCaseUUID;
    callData.operatorName = operatorName;
    getRecordAccess();
}
function updateCallData (phoneNumber, extensionNumber, callMode) {
    if (OperatorConsole.naumenCaseUUID == null) return; // case processing is finished
    callData.callPhoneNumber = phoneNumber.length == 10 ? '+7'+phoneNumber : phoneNumber; 
    callData.callExtensionNumber = extensionNumber == null || extensionNumber == '' || extensionNumber == 'undefined' ? null : extensionNumber;
    callData.callMode = callMode; // may be = null or "PROCESSING"
    setPhoneField();
    processCallMode();
}
function closeRecord () {
    console.log('closeRecord');
    closeRecord_ProcessingTimeIsFinished(callData.naumenCaseUUID, callData.operatorName);
    callData = {};
}
// record is saved in the console 
function onRecordSaved () {
    //used when: 
    // (1) 1st cal data is saved before making the 2nd call (immediate call) while processing the record
    // (2) operator finished proseccing the record and saved call results
    if (OperatorConsole != null) OperatorConsole.onRecordSavedInConsole(); // send message event to the softphone
    callData = {}; // clear call params
}
// record was closed in the console (console is ready for a new call)
function onCaseClosed () {
    onRecordSaved (); // clear call data and send message event to sofpthone
    if (OperatorConsole != null) OperatorConsole.onCaseClosedInConsole(); // clear Naumen case params
}
// set phone number for which the call results will be saved
function setPhoneField () {
    console.log('setPhoneField >> ' + callData.callPhoneNumber + ' ext : ' + callData.callExtensionNumber);
    if (callData.callPhoneNumber != null) {
        // set phone number which we got from Naumen
        $j('#callPhoneNumber').text(callData.callPhoneNumber);
        document.getElementById('RecordAssignCheckRu:pdRecordForm:inputPhoneField').value = callData.callPhoneNumber;
        if (callData.callExtensionNumber != null) document.getElementById('RecordAssignCheckRu:pdRecordForm:inputCallExtensionNumber').value = callData.callExtensionNumber;
        hideInputPhone (); // user is unable to change the main phone number since we set the call phone number
    } else {
        showInputPhone (); // user is able to change phone number if the record was opened not from Naumen call
    }
    defineNumberMask ($j('.input-Phone'), true); // use defineNumberMask from PD Forms JS
    defineNumberMask ($j('.input-Phone2'), true); // use defineNumberMask from PD Forms JS
}
// event when user changes extension number in the console
function onChangeInputExtNumber() {
    if (OperatorConsole != null) {
        var newVal = document.getElementById('RecordAssignCheckRu:pdRecordForm:inputCallExtensionNumber').value;
        callData.callExtensionNumber = newVal;
        var callDataToUpdateInSoftphone = {extensionNumber: newVal};
        OperatorConsole.onCallDataChanged(callDataToUpdateInSoftphone); // send extension number to softphone
    }
}
// set operator console UI depending on the call mode which we got from softphone
function processCallMode () {
// show Save button if softphone is in processing mode and hide it if it's in any another mode
    if (OperatorConsole == null) return;
    if (callData.callMode == null && callData.callPhoneNumber != null) {
        disableSaveButton(true);
    } else {
        disableSaveButton(false);
    }
}
// show input which lets user to change the main phone on the customer record
function showInputPhone () {
    $j('#inputPhoneBlock').css('display', 'block'); // show input phone
    $j('#callPhoneExtensionBlock').css('display', 'none'); // hide input extension (as extension is being entered in the phone input)
}
// hide input phone so the user is not able to change the main phone on the customer record
function hideInputPhone () {
    $j('#inputPhoneBlock').css('display', 'none'); // hide input phone
    $j('#callPhoneExtensionBlock').css('display', 'inline');  // show input extension
}
// define either operator can use transfer calls functionality for the current record or not
var isTransferCallAvailable = function () {
    var options = $j('.activityType>option');
    for (var i=0; i < options.size(); i++) {
         var activityName = $j(options[i]).val();
         //console.log(activityName);
         if (activityName == 'Online transfer call') {
            return true;
         }
    }
    return false;
}

//Function is used to get splash status bar when server side call is going on
function startSplash() {
    document.getElementById('splashDiv').style.display='table-cell';
    jQuery('.lightbox').fadeIn(50);
    $('html, body').css({
        overflow: 'hidden',
        height: 'auto'
    });
    $("body").css("padding-right", "17px");
}

//Function will make the splash status to be stopped.
function endSplash() {
    document.getElementById('splashDiv').style.display='none';
    jQuery('.lightbox').fadeOut(50);
    $('html, body').css({
        overflow: '',
        height: ''
    });
    $("body").css("padding-right", "");
}

function showAdditionalPhone(){
    $j('.input-Phone2').parent().parent().removeClass( "input-hidden" );
    $j('.input-Phone').parent().css("padding","0px 15px 0px 15px");
    $j('.input-Phone').parent().removeClass("col-xs-6 col-lg-6 col-md-6 col-sm-6");
    $j('.input-Phone').parent().addClass("col-xs-7 col-lg-7 col-md-7 col-sm-7");
    $j('.additionalPhoneButton').parent().addClass( "input-hidden" );
}

function showAdditionalEmail(){
    $j('.input-Email2').parent().parent().removeClass( "input-hidden" );
    $j('.input-Email').parent().css("padding", "0px 15px 0px 15px");
    $j('.input-Email').parent().removeClass("col-xs-6 col-lg-6 col-md-6 col-sm-6");
    $j('.input-Email').parent().addClass("col-xs-7 col-lg-7 col-md-7 col-sm-7");
    $j('.additionalEmailButton').parent().addClass( "input-hidden" );
}

function changeKeyParameters(){
    setUpResultTypeList();
    onChangeResultType();
}

function setUpResultTypeList(){
    var bigClient = $j('[id$=big-client]').val();
    var recordStatus = $j('[id$=params-record-status]').val();
    var regionFS = $j('[id$=params-region-fs]').val();

    var selectList = document.getElementsByClassName('activityType')[0];
    var options = selectList.getElementsByTagName("option");
    for(i = 0; i < options.length; i++){
        if(options[i].value == 'Meeting'){
             if(bigClient == 'true' && regionFS == 'true' && recordStatus == 'Free'){
                 options[i].style.display = "block";
             } else {
                 options[i].style.display = "none";
             }
             break;
        }
    }
}

function onChangeResultType(){
    var recordStatus = $j('[id$=params-record-status]').val();
    var selectList = document.getElementsByClassName('activityType')[0];
    var ownerOfRecord = document.getElementsByClassName('ownerOfRecord')[0];
    var disqualReasonBlock = document.getElementById('disqualReasonBlock');
    var callBackParamsBlock = document.getElementById('callBackParamsBlock');
    
    if(recordStatus == 'Free' && selectList.value == 'Online transfer call'){
        ownerOfRecord.style.display = "block";
    } else {
        ownerOfRecord.style.display = "none";
    }
    if (OperatorConsole != null) {
        // show disqual reasons if Disqualification call result was selected by the user
        if(selectList.value == 'Disqualification') {
            disqualReasonBlock.style.display = "block";
        } else {
            disqualReasonBlock.style.display = "none";
        }
        // show/hide params to set callback for the current Naumen case
        if(selectList.value == 'Callback' && $j('.input-Phone2').val().length > 0 && isValidPhoneFormatRU($j('.input-Phone2'))) {
            callBackParamsBlock.style.display = "block";
        } else {
            callBackParamsBlock.style.display = "none";
        }
    }
}
function saveRecord() { // save record and close
    console.log('>> in >> saveRecord ');
    showSaveButton(false); 
    startSubmitProcess(); 
}
function saveCurrentCallData() { // save current call phone data and don't close the record
    console.log('>> in >> saveCurrentCallData');
    savePhonesData();
}
function submitProcess(){
    setUpResultTypeList();
    onChangeResultType();
    var emailAddress = $j('.input-Email').parent();
    var emailAddressSecond = $j('.input-Email2').parent();
    //var phone = $j('.input-Phone').parent();
    //var phoneSecond = $j('.input-Phone2').parent();
    var activityType = $j('.activityType').parent().parent();
    
    var isValid = false;

    var validatedFields = [];
    validatedFields.push(isInputValueValid(emailAddress, new RegExp(regs.email)));
    validatedFields.push(isInputValueValid(emailAddressSecond, new RegExp(regs.email)));
    //validatedFields.push(isInputValueValid(phone, new RegExp(regs.phone)));
    //validatedFields.push(isInputValueValid(phoneSecond, new RegExp(regs.phone)));
    validatedFields.push(isInputValueValid_Phone($j('.input-Phone')));
    validatedFields.push(isInputValueValid_Phone($j('.input-Phone2')));
    validatedFields.push(isActivityTypeValid(activityType));

    if ($j('.ownerOfRecord').css('display') == 'block') {
        var managerOwner = $j('.currentMember').parent().parent();
        validatedFields.push(isManagerOwnerValid(managerOwner));
    }
    if (OperatorConsole != null) {
        var disqualReasonList = $j('.disqualReasonList').parent().parent();
        validatedFields.push(isDisqualReasonValid(disqualReasonList));
    }
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    if(isValid){ // entered data is valid
       var CTIEnabled =  OperatorConsole != null;
       if (CTIEnabled) {
           OperatorConsole.onProcessingIsFinished(); // send message event to close the call form in softphone
           showSaveButton(false);
           OperatorConsole.onActiveCallClosed = function () { // save call results in controller when call for is closed in softphone
               submitFormCtrl(CTIEnabled, callData.naumenProjectUUID, callData.naumenCaseUUID, callData.operatorName);
           }
       } else {
           // save call results in controller
           submitFormCtrl(CTIEnabled, callData.naumenProjectUUID, callData.naumenCaseUUID, callData.operatorName);
       }
    } else { // entered data is invalid
       showSaveButton(true);
    }
}

function isInputValueValid(element, regex){
    var isValid = false;
    var elementValue = element.find(':input').val();
    if((elementValue.trim() == '') || regex.test(elementValue)){
        element.find(".error").removeClass("show-error-block");
        element.find(':input').removeClass("input-error");
        isValid = true;
    } else {
        element.find(".error").addClass("show-error-block");
        element.find(':input').addClass("input-error");
        isValid = false;
    }
    return isValid;
}
function isInputValueValid_Phone (elem) {
    var isValid = isValidPhoneFormatRU (elem);
    if (isValid == false) {
        elem.parent().find(".error").addClass("show-error-block");
        elem.parent().find(':input').addClass("input-error");
    }
    return isValid;
}
function isActivityTypeValid(element){
    var isValid = true;
    element.find(".error").removeClass("show-error-block");
    element.find('.activityType').removeClass("input-error");

    var selectList = document.getElementsByClassName('activityType')[0];
    var options = selectList.getElementsByTagName("option");
    for(i = 0; i < options.length; i++){
        if(options[i].value == 'Meeting'){
            if(options[i].style.display == "none" && selectList.value == 'Meeting'){
                element.find(".error").addClass("show-error-block");
                element.find('.activityType').addClass("input-error");
                isValid = false;
            }
            break;
        }
    }
    return isValid;
}
function isManagerOwnerValid(element){
    var isValid = true;
    element.find(".error").removeClass("show-error-block");
    element.find('.currentMember').removeClass("input-error");
    var selectedVal = $j(".currentMember").val();
    if(selectedVal == ''){
        element.find(".error").addClass("show-error-block");
        element.find('.currentMember').addClass("input-error");
        isValid = false;
    }
    console.log('selectedVal : ' + selectedVal);
    console.log('isManagerOwnerValid : ' + isValid);
    return isValid;
}
function isDisqualReasonValid(element){
    var isValid = true;
    element.find(".error").removeClass("show-error-block");
    element.find('.disqualReason').removeClass("input-error");
    var activityType = document.getElementsByClassName('activityType')[0];
    if(activityType.value == 'Disqualification') {
        var disqualReasonList = document.getElementsByClassName('disqualReasonList')[0];
        isValid = disqualReasonList.value != null && disqualReasonList.value != ''; // empty disqualification reason
    }
    if (isValid == false) {
        element.find(".error").addClass("show-error-block");
        element.find(':input').addClass("input-error");
    }
    return isValid;
}

function showSaveButton(val){
    if(val){
        $j('.saveButton').removeClass( "input-hidden" );
    } else {
        $j('.saveButton').addClass( "input-hidden" );
    }
}
function disableSaveButton(val){
    if(val){
        $j('.saveButton').addClass('notclickable');
    } else {
        $j('.saveButton').removeClass('notclickable');
    }
}

/*
function savePersonalData() {
   var data = {};
   console.log('ALERT');
   data['FirstName'] = document.getElementsByClassName('input-FirstName')[0].value;
   data['MiddleName'] = document.getElementsByClassName('input-MiddleName')[0].value;
   data['LastName'] = document.getElementsByClassName('input-LastName')[0].value;
   data['Phone'] = document.getElementsByClassName('input-Phone')[0].value;
   data['Email'] = document.getElementsByClassName('input-Email')[0].value;
   data['Title'] = document.getElementsByClassName('input-Title')[0].value;
   var dataJSON = JSON.stringify(data);

   var body = {};
   body['token'] = '{!PD_Token}';
   body['data'] = data;
   body['id'] = document.getElementById('{!$Component.pdRecordForm.PD_ExternalId}').value;

   var xhr = new XMLHttpRequest();
   xhr.open("POST", '{!PD_URL}/save-data', true);
   xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
   xhr.onreadystatechange = function () {
       console.log(xhr.readyState);
       if(xhr.readyState === XMLHttpRequest.DONE) {
           if (xhr.status === 200) {
               var responseJSON = JSON.parse(xhr.responseText);
               if (responseJSON.status == 'error') {
                   console.log(responseJSON.error.message);
                   return false;
               } else {
                   var idField = document.getElementById('{!$Component.pdRecordForm.PD_ExternalId}');
                   idField.value = responseJSON.result.id;
                   updateData();
                   return true;
               }
           } else {
               console.log('Label.pd_server_error');
               return false;
           }
       };
   };
   console.log(JSON.stringify(body));
   xhr.send(JSON.stringify(body));
}
*/