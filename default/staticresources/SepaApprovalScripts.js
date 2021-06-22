function runValidation() {
    var accountHolderInput = $('.account-holder').find('input');
    if(accountHolderInput.val() != '' && accountHolderInput.val() != undefined) {
        isInputValueValid(accountHolderInput, new RegExp(regs.letters));
    }
    accountHolderInput.on('input', function(e){
        isInputValueValid(accountHolderInput, new RegExp(regs.letters));
    });    

    var ibanInput = $('.iban').find('input');
    if(ibanInput.val() != '' && ibanInput.val() != undefined) {
        isInputValueValid(ibanInput, new RegExp(regs.ibanFormat));
    }
    ibanInput.on('input', function(e){
        isInputValueValid(ibanInput, new RegExp(regs.ibanFormat));
    });    

    var swiftInput = $('.swift').find('input');
    if(swiftInput.val() != '' && swiftInput.val() != undefined) {
        isInputValueValid(swiftInput, new RegExp(regs.swiftFormat));
    }
    swiftInput.on('input', function(e){
        isInputValueValid(swiftInput, new RegExp(regs.swiftFormat));
    }); 	

    var allAgreements = $('.sepa-content').find('input[type="checkbox"].form-check-input');
    var confirmedAgreements = [];
    allAgreements.each(function(){
        if($(this).is(':checked')){
            confirmedAgreements.push(true);
        } else {
            confirmedAgreements.push(false);
        }
    });
    if(confirmedAgreements.indexOf(false) != -1){
        $('.btn-red.continue').attr('disabled', true);
    }

    allAgreements.click(function(){
        confirmedAgreements = [];
        allAgreements.each(function(){
            if($(this).is(':checked')){
                confirmedAgreements.push(true);
            } else {
                confirmedAgreements.push(false);
            }
        });
        if(confirmedAgreements.indexOf(false) == -1){
            checkRequiredFields();
        } else {
           $('.btn-red.continue').attr('disabled', true);
        }
    });

    var requiredInputs = $('.sepa-content').find('.form-control.required');
    requiredInputs.keyup(function() {
        if(confirmedAgreements.indexOf(false) == -1){
            checkRequiredFields();
        } else {
            $('.btn-red.continue').attr('disabled', true);
        }
    });
}

function isInputValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    if((elementValue.trim() != '') && regex.test(elementValue)){
        element.closest('.form-group input').removeClass('error');
        element.closest('.form-group input').addClass('success');
        element.closest('.form-group').find('.invalid-feedback').hide();
        element.closest('.form-group').find('.glyphicon').show();
        isValid = true;
    } else {
        element.closest('.form-group input').removeClass('success');
        element.closest('.form-group input').addClass('error');
        element.closest('.form-group').find('.invalid-feedback').show();
        element.closest('.form-group').find('.glyphicon').hide();
        isValid = false;
    }
    return isValid;
}

function checkRequiredFields() {
    var accountHolderIsValid = false;
    var accountHolderInput = $('.account-holder').find('input');
    if(accountHolderInput.val() != '' && accountHolderInput.val() != undefined) {
        accountHolderIsValid = isInputValueValid(accountHolderInput, new RegExp(regs.letters));
    }
    var ibanIsValid = false;
    var ibanInput = $('.iban').find('input');
    if(ibanInput.val() != '' && ibanInput.val() != undefined) {
        ibanIsValid = isInputValueValid(ibanInput, new RegExp(regs.ibanFormat));
    }
    var swiftIsValid = false;
    var swiftInput = $('.swift').find('input');
    if(swiftInput.val() != '' && swiftInput.val() != undefined) {
        swiftIsValid = isInputValueValid(swiftInput, new RegExp(regs.swiftFormat));
    }

    if (! accountHolderIsValid || ! ibanIsValid || ! swiftIsValid) {
        $('.btn-red.continue').attr('disabled', true);
    } else {
        $('.btn-red.continue').attr('disabled', false);
    }
}