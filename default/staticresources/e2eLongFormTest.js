j$ = jQuery.noConflict();

var supportedCountry = 'Germany';
var regs = {
    phone: /^[0-9+]+$/,
    numbers: /^[0-9]+$/,
    letters: /^[a-zA-ZÀ-ž\x7f-\xff\s'-]+$/,
    lettersAndNumbers: /^[0-9a-zA-ZÀ-ž\x7f-\xff\s'-]+$/,
    email: /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/,
    swiftFormat: /^([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$/,
    ibanFormat: /^[a-zA-Z]{2}[0-9]{2}\s?[a-zA-Z0-9]{4}\s?[0-9]{4}\s?[0-9]{3}([a-zA-Z0-9]\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,4}\s?[a-zA-Z0-9]{0,3})?$/
};

j$(document).ready(function () {
    var content = j$('.step-content');

    j$('[data-toggle="popover"]').popover();

    var firstNameInput = content.find('.first-name').find('input');
    firstNameInput.on('input', function(e){
        isInputValueValid(firstNameInput, new RegExp(regs.letters));
    });

    var lastNameInput = content.find('.last-name').find('input');
    lastNameInput.on('input', function(e){
        isInputValueValid(lastNameInput, new RegExp(regs.letters));
    });

    var phoneInput = content.find('.phone').find('input');
    phoneInput.mask('+00000000000000');
    phoneInput.on('input', function(e){
        isInputValueValid(phoneInput, new RegExp(regs.phone));
    });

    var emailInput = content.find('.email').find('input');
    emailInput.on('input', function (e){
        isInputValueValid(emailInput, new RegExp(regs.email));
    });

    var companyInput = content.find('.company').find('input');
    companyInput.on('input', function(e){
        isInputValueValid(companyInput, new RegExp(regs.lettersAndNumbers));
    });

    var accountHolderInput = content.find('.account-holder').find('input');
    accountHolderInput.on('input', function(e){
        isInputValueValid(accountHolderInput, new RegExp(regs.letters));
    });

    var ibanInput = content.find('.iban').find('input');
    ibanInput.on('input', function(e){
        isInputValueValid(ibanInput, new RegExp(regs.ibanFormat));
    });

    var swiftInput = content.find('.swift').find('input');
    swiftInput.on('input', function(e){
        isInputValueValid(swiftInput, new RegExp(regs.swiftFormat));
    });

    var pupmInput = content.find('.plan-pump-fuel').find('input');
    pupmInput.mask('00000');
    pupmInput.on('input', function(e){
        isInputValueValid(pupmInput, new RegExp(regs.numbers));
    });

    var modalDialog = j$('.modal-dialog');
    var projectPump = modalDialog.find('.project-pump').find('input');
    projectPump.mask('00000');

    var paymentMethodSelect = j$('.method-radio');
    paymentMethodSelect.on('change', function() {
        if(paymentMethodSelect.find('input:radio:checked').val().toUpperCase() == 'NO') {
            j$('.pay-method').find('.warning-message').show();
        } else {
            j$('.pay-method').find('.warning-message').hide();
        }
    });

    var invoiceFormatSelect = j$('.invoice-format');
    invoiceFormatSelect.on('change', function(){
        if(invoiceFormatSelect.find('input:radio:checked').val().toUpperCase() == 'YES') {
            j$('.invoice').find('.warning-message').show();
        } else {
            j$('.invoice').find('.warning-message').hide();
        }
    });

    j$(function(){
        //calling the createSlider Method to create the slider in designated location
        createSlider('slider', 'limit', 'idInputHidden', 0, 0, 1000);
    });

    var spinnerVal = parseInt(j$('.spinner input').val());

    j$('.spinner .btn:last-of-type').on('click', function() {
        if(spinnerVal > 0) {
            j$('.spinner input').val( parseInt(j$('.spinner input').val(), 10) - 1);
        }
    });

    j$('.spinner .btn:first-of-type').on('click', function() {
        j$('.spinner input').val( parseInt(j$('.spinner input').val(), 10) + 1);
    });

});

function isInputValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    if((elementValue.trim() != '') && regex.test(elementValue)){
        element.closest('.form-group').removeClass('has-error');
        element.closest('.form-group').addClass('has-success');
        element.closest('.form-group').find('.invalid-feedback').hide();
        element.closest('.form-group').find('.glyphicon.glyphicon-remove').hide();
        element.closest('.form-group').find('.glyphicon.glyphicon-ok').show();
        isValid = true;
    } else {
        element.closest('.form-group').removeClass('has-success');
        element.closest('.form-group').addClass('has-error');
        element.closest('.form-group').find('.invalid-feedback').show();
        element.closest('.form-group').find('.glyphicon.glyphicon-ok').hide();
        element.closest('.form-group').find('.glyphicon.glyphicon-remove').show();
        isValid = false;
    }
    return isValid;
}

function validateContactDetails(){
    var content = j$('.step-content');
    var firstNameInput = content.find('.first-name').find('input');
    var lastNameInput = content.find('.last-name').find('input');
    var phoneInput = content.find('.phone').find('input');
    var emailInput = content.find('.email').find('input');
    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(firstNameInput, new RegExp(regs.letters)));
    validatedFields.push(isInputValueValid(lastNameInput, new RegExp(regs.letters)));
    validatedFields.push(isInputValueValid(phoneInput, new RegExp(regs.phone)));
    validatedFields.push(isInputValueValid(emailInput, new RegExp(regs.email)));
    isValid = validatedFields.includes(false) ? false : true;
    if(isValid){
       saveContactDetails();
    } else {
       return false;
    }
}

function validateCreditParams(){
    var content = j$('.step-content');
    var companyInput = content.find('.company').find('input');
    var accountHolderInput = content.find('.account-holder').find('input');
    var ibanInput = content.find('.iban').find('input');
    var swiftInput = content.find('.swift').find('input');
    var pumpInput = content.find('.plan-pump-fuel').find('input');
    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(companyInput, regs.lettersAndNumbers));
    validatedFields.push(isInputValueValid(accountHolderInput, regs.letters));
    validatedFields.push(isInputValueValid(ibanInput, regs.ibanFormat));
    validatedFields.push(isInputValueValid(swiftInput, regs.swiftFormat));
    validatedFields.push(isInputValueValid(pumpInput, regs.numbers));
    isValid = validatedFields.includes(false) ? false : true;
        if(isValid){
            runCreditScore();
        } else {
            return false;
    }
}

function createSlider(destination, limitOutput ,idInputHidden ,startVal, minVal, maxVal){
    j$('#' + destination).slider({
        range: false,
        min: minVal,
        max: maxVal,
        values: [startVal],
        slide: function(event, ui){
            //This function executes every time slider is moved and applies the slider values
            //to the input fields as well as the output below the slider
            j$('[id$="+ idInputHidden +"]').val(ui.values[0]);
            j$('#' + limitOutput).html(ui.values[0] + ' €');
        }
    });
    //write the initial value in the display div
    j$('#' + limitOutput).html(startVal + ' €');
}