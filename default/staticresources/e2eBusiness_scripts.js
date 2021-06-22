$j = jQuery.noConflict();

var noData = 'нет данных';
var allowPaidOverdraft = false;

var regs = {
    phone: /^((8|\+7)[\- ]?)?(\d{3}[\- ]?)?[\d ]{7,10}$/,
    inn: /^\d{10}|\d{12}$/,
    email: /^([\w-\.]+@([\w-]+\.)+[\w-]{2,7})?$/,
    companyName: /^[0-9a-zA-Zа-яА-ЯёЁ\w"\s"'`/()&@,;!?$#№%.+-]+$/,
    numbers: /^[0-9]+$/,
    letters: /^[а-яА-ЯёЁ\s'-]+$/,
    address: /^[0-9а-яА-ЯёЁIVX\s,.'"\/()-]+$/,
    bankName: /^[0-9nN№а-яА-ЯёЁ\s,."'()!-]+$/,
    position: /^[а-яА-Я\s.'-]+$/,
    codeWord: /^[а-яА-ЯёЁ]+$/,
    passportCode: /^(\d{3})([\-]{1})(\d{3})$/,
    date: /^(0[1-9]|[12][0-9]|3[01])[.](0[1-9]|1[012])[.](19|20)\d\d$/,
    okpo: /^[0-9]{8}(?:[0-9]{2})?$/
};

var decisionTypes = {
    0 : 'COMPANY_CHECK',
    1 : 'SCORE_CHECK'
}

$j(document).ready(function(){

    $j('html').attr('lang', 'ru');

    setEvents_contactDetails();

    setEvents_companyDetails();

    setEvents_order();

    setEvents_legalDetails();

    setEvents_paymentDetails();

    dadataLegalAddress();

    dadataDocumentAddress();

    dadataBank();

    checkFinalResponse();
});

// ----- Contact Details ----- //
function setEvents_contactDetails() {
    var currentStepBlock = $j('.contact-details');
    var phoneNumber = $j('.contact-phone').find('input');
    if(phoneNumber.val().length == 10 && phoneNumber.val().startsWith('7')){
        var correctPhone = '7' + phoneNumber.val();
        phoneNumber.val(correctPhone);
    }

    delete $j.jMaskGlobals.translation['9'];
    phoneNumber.mask('+7 900 000 00 00');
    checkForAutoPasteNumericValues(phoneNumber);

    var emailAddress = $j('.contact-email').find('input');
    checkForAutoPasteValues(emailAddress, new RegExp(regs.email));

    var fullName = $j('.contact-name').find('input');
    checkForAutoPasteValues(fullName, new RegExp(regs.letters));

    validateContactDetails();
    checkInputLength(phoneNumber, 16);

    phoneNumber.blur(function(){
        isInputValueValid($j(this), new RegExp(regs.phone));
        checkInputLengthOnInput(phoneNumber, 16);
        controlCheckMark(currentStepBlock, $j(this));
    });

    phoneNumber.on('input',function(){
        isInputValueValidOnInput($j(this), new RegExp(regs.phone));
        checkInputLengthOnInput(phoneNumber, 16);
        controlCheckMark(currentStepBlock, $j(this));
    });

    emailAddress.blur(function(){
        isInputValueValid($j(this), new RegExp(regs.email));
        controlCheckMark(currentStepBlock, $j(this));
    });

    emailAddress.on('input',function(){
        isInputValueValidOnInput($j(this), new RegExp(regs.email));
        controlCheckMark(currentStepBlock, $j(this));
    });

    fullName.blur(function(){
        isInputValueValid($j(this), new RegExp(regs.letters));
        controlCheckMark(currentStepBlock, $j(this));
    });

    fullName.on(function(){
        isInputValueValidOnInput($j(this), new RegExp(regs.letters));
        controlCheckMark(currentStepBlock, $j(this));
    });
}

function validateContactDetails(){
    var currentStepBlock = $j('.contact-details');
    var phoneNumber = $j('.contact-phone').find('input');
    var emailAddress = $j('.contact-email').find('input');
    var fullName = $j('.contact-name').find('input');

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(phoneNumber, new RegExp(regs.phone)));
    validatedFields.push(isInputValueValid(emailAddress, new RegExp(regs.email)));
    validatedFields.push(isInputValueValid(fullName, new RegExp(regs.letters)));
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    var checkMark = currentStepBlock.find('.checkmark');
    if(isValid){
        currentStepBlock.addClass('done');
        checkMark.show();
    } else {
        currentStepBlock.removeClass('done');
        checkMark.hide();
    }
}
// ----- END Contact Details ----- //

// ----- Company Details ----- //
function setEvents_companyDetails(){
    var currentStepBlock = $j('.company-details');
    var companyName = $j('.company-name').find('input');
    checkForAutoPasteValues(companyName, new RegExp(regs.companyName));

    var buttonProcess = $j('.btn.process');
    var verifiedDecision = $j('.verified-decision .data');
    var verifiedDecisionValue = verifiedDecision.text().trim();
    if (verifiedDecisionValue === 'Отказ') {
        buttonProcess.addClass('disabled');
        verifiedDecision.addClass('refused');
    }

    if (verifiedDecisionValue === 'Согласование перекупщика' || verifiedDecisionValue === 'Согласование с ОУР') {
        verifiedDecision.addClass('refused');

        // approvalProcessRMDActive declared in page
        if (!approvalProcessRMDActive) {
            buttonProcess.addClass('disabled');
        }
    }

    var scoringDecision = $j('.scoring-decision .data');
    var scoringDecisionValue = scoringDecision.text().trim();
    if(scoringDecisionValue === 'Отказ'){
        buttonProcess.addClass('disabled');
        scoringDecision.addClass('refused');
    }

    validateCompanyDetails();

    companyName.blur(function(){
        isInputValueValid($j(this), new RegExp(regs.companyName));
        controlCheckMark(currentStepBlock, $j(this));
    });

    if($j('.scoring-decision .data').text().trim() == 'Платный овердрафт'){
        allowPaidOverdraft = true;
        $j('.paid-overdraft').show();
    }
}

function validateCompanyDetails(){
    var currentStepBlock = $j('.company-details');
    var companyName = $j('.company-name').find('input');
    var isSoleProprietor = $j('[id$=isSoleProprietor]').val();

    var dataFields = currentStepBlock.find('.data');
    var hasData = true;
    currentStepBlock.addClass('has-data');
    dataFields.each(function(){
        if(isSoleProprietor === 'true'){
            // if isSoleProprietor check only 3 fields have data, cause we don't score soles
            if(($j(this).parent().hasClass('.company-name-spark') ||
                $j(this).parent().hasClass('.company-inn') ||
                $j(this).parent().hasClass('.verified-decision')) &&
                $j(this).text().trim() === noData){
                hasData = false;
                currentStepBlock.removeClass('has-data');
            }
        } else {
            // if company check all fields
            if($j(this).text().trim() === noData){
                hasData = false;
                currentStepBlock.removeClass('has-data');
                return;
            }
        }
    });

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(companyName, new RegExp(regs.companyName)));
    validatedFields.push(hasData);
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    var checkMark = currentStepBlock.find('.checkmark');
    if(isValid){
        currentStepBlock.addClass('done');
        checkMark.show();
    } else {
        currentStepBlock.removeClass('done');
        checkMark.hide();
    }
}
// ----- END Company Details ----- //

// ----- Order and Tariff ----- //
function setEvents_order(){
    var currentStepBlock = $j('.tariffs');
    var cardNum = $j('.card-counter').find('input');
    checkForAutoPasteNumericValues(cardNum);

    validateOrder();

    var checkMark = currentStepBlock.find('.checkmark');
    cardNum.blur(function(){
        var cardsLimit = parseInt($j('[id$=cardsLimit]').val());
        var cardCount = parseInt(cardNum.val());
        if((cardCount > cardsLimit)){
            cardNum.addClass('error').removeClass('valid');
            $j('.card-message').text('Договор МО не может быть заключен на ' + cardCount +
                                        ' карт. Необходимо оформить договор МПД через Зохо.');
        } else if (cardCount == 0){
            cardNum.addClass('error').removeClass('valid');
        } else {
            isInputValueValid($j(this), new RegExp(regs.numbers));
            $j('.card-message').text('');
        }
        controlCheckMark(currentStepBlock, $j(this));
    });

    $j('.additional-promo-code-checkbox').find('input').change(function() {
        if($j('.additional-promo-code-checkbox').find('input').is(':checked') == true) {
            $j('.additional-promo-code').show();
        } else {
            $j('.additional-promo-code').hide();
        }
    });
}

function validateOrder(){
    var currentStepBlock = $j('.tariffs');
    var cardNum = $j('.card-counter').find('input');

    var cardsLimit = parseInt($j('[id$=cardsLimit]').val());
    var cardCount = parseInt(cardNum.val());
    if((cardCount > cardsLimit)){
        cardNum.addClass('error').removeClass('valid');
        $j('.card-message').text('Договор МО не может быть заключен на ' + cardCount +
                                    ' карт. Необходимо оформить договор МПД через Зохо.');
    } else if (cardCount == 0){
        cardNum.addClass('error').removeClass('valid');
    } else {
        isInputValueValid(cardNum, new RegExp(regs.numbers));
        $j('.card-message').text('');
    }

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(cardNum.val() > 0 && isInputValueValid(cardNum, new RegExp(regs.numbers)));
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    var checkMark = currentStepBlock.find('.checkmark');
    if(isValid){
        currentStepBlock.addClass('done');
        checkMark.show();
    } else {
        currentStepBlock.removeClass('done');
        checkMark.hide();
    }
};

function validatePromocodes() {
    var tariffsBlock = $j('.tariffs');
    var checkMark = tariffsBlock.find('.checkmark');
    var selectedCodeTarget = window.event.target;
    var firstPromocodeSelect;
    var secondPromocodeSelect;

    if (selectedCodeTarget && selectedCodeTarget.type === 'select-one' && selectedCodeTarget.type !== 'checkbox') {
        firstPromocodeSelect = selectedCodeTarget;
        var secondPromocodeClassName = (firstPromocodeSelect.parentElement.className === 'additional-promo-code') ? '.promo-code' : '.additional-promo-code';
        secondPromocodeSelect = $j(secondPromocodeClassName).find('select')[0];
    } else {
        firstPromocodeSelect = $j('.promo-code').find('select')[0];
        secondPromocodeSelect = $j('.additional-promo-code').find('select')[0];
    }

    var additionalPromoCodeCheckboxChecked = tariffsBlock.find('div.additional-promo-code-checkbox div.checkbox input')[0].checked;

    if (additionalPromoCodeCheckboxChecked && firstPromocodeSelect.value === secondPromocodeSelect.value ) {
        tariffsBlock.removeClass('done');
        checkMark.hide();
        $j('.promo-code-error').text('Одна и та же акция не может быть в 2-ух спискаx');
    } else {
        tariffsBlock.addClass('done');
        checkMark.show();
        $j('.promo-code-error').text('');
    }
}
// ----- END Tariffs ----- //

// ----- Legal Details ----- //
function setEvents_legalDetails(){
    //VS SF-619
    //VS SF-617
    var currentStepBlock = $j('.legal-details');
    if ($j('[id$=isSoleProprietor]').val() == "false") {
        var kpp = $j('.kpp').find('input');
        if(kpp.val().length < 9){
            kpp.val('0' + kpp.val());
        }
    }

    validateLegalDetails();

    var ogrn = $j('.ogrn').find('input');
    checkForAutoPasteNumericValues(ogrn);
    ogrn.blur(function(e){
        isLegalInputValueValid(ogrn, new RegExp(regs.numbers), 13, false);
        controlCheckMark(currentStepBlock, $j(this));
    });
    ogrn.on('input', function(){
        isLegalInputValueValidOnInput(ogrn, new RegExp(regs.numbers), 13, false);
        controlCheckMark(currentStepBlock, $j(this));
    });

    var ogrnip = $j('.ogrnip').find('input');
    checkForAutoPasteNumericValues(ogrnip);
    ogrnip.blur(function(e){
        isLegalInputValueValid(ogrnip, new RegExp(regs.numbers), 15, false);
        controlCheckMark(currentStepBlock, $j(this));
    });
    ogrnip.on('input', function(){
        isLegalInputValueValidOnInput(ogrnip, new RegExp(regs.numbers), 15, false);
        controlCheckMark(currentStepBlock, $j(this));
    });

    var kpp = $j('.kpp').find('input');
    checkForAutoPasteNumericValues(kpp);
    kpp.blur(function(e){
        isLegalInputValueValid(kpp, new RegExp(regs.numbers), 9, false);
        controlCheckMark(currentStepBlock, $j(this));
    });
    kpp.on('input',function(){
        isLegalInputValueValidOnInput(kpp, new RegExp(regs.numbers), 9, false);
        controlCheckMark(currentStepBlock, $j(this));
    });

    var okpo = $j('.okpo').find('input');
    checkForAutoPasteNumericValues(okpo);
    okpo.blur(function(e){
        validateJQueryElement(okpo, regs.okpo);
        controlCheckMark(currentStepBlock, $j(this));
    });
    okpo.on('input', function(){
        validateJQueryElementOnInput(okpo, regs.okpo);
        controlCheckMark(currentStepBlock, $j(this));
    });

    var legalAddress = $j('.legal-address-block').find('textarea');
    checkForAutoPasteValues(legalAddress, new RegExp(regs.address));
    legalAddress.blur(function(e){
        isInputValueValid(legalAddress, new RegExp(regs.address));
        validateAddressInformation(legalAddress.parent());
        controlCheckMark(currentStepBlock, $j(this));
    });

    var documentAddress = $j('.post-address').find('textarea');
    checkForAutoPasteValues(documentAddress, new RegExp(regs.address));
    documentAddress.blur(function(e){
        isInputValueValid(documentAddress, new RegExp(regs.address));
        validateAddressInformation(documentAddress.parent());
        controlCheckMark(currentStepBlock, $j(this));
    });

    var executiveName = $j('.executive-name').find('input');
    checkForAutoPasteNumericValues(okpo);
    executiveName.blur(function(e){
        isInputValueValid(executiveName, new RegExp(regs.letters));
        controlCheckMark(currentStepBlock, $j(this));
    });
    executiveName.on('input', function(){
        isInputValueValidOnInput(executiveName, new RegExp(regs.letters));
        controlCheckMark(currentStepBlock, $j(this));
    });

    var executivePosition = $j('.executive-position').find('input');
    checkForAutoPasteValues(executivePosition);
    executivePosition.blur(function(e){
        isInputValueValid(executivePosition, new RegExp(regs.letters));
        controlCheckMark(currentStepBlock, $j(this));
    });
    executivePosition.on('input', function(){
        isInputValueValidOnInput(executivePosition, new RegExp(regs.letters));
        controlCheckMark(currentStepBlock, $j(this));
    });

    var codeWord = $j('.code-word').find('input');
    checkForAutoPasteValues(codeWord);
    codeWord.blur(function(e){
        isCodeWordValueValid(codeWord, new RegExp(regs.codeWord));
        controlCheckMark(currentStepBlock, $j(this));
    });
    codeWord.on('input', function(){
        isCodeWordValueValid(codeWord, new RegExp(regs.codeWord));
        controlCheckMark(currentStepBlock, $j(this));
    });

    var personalOfficeEmail = $j('.personal-office-email').find('input');
    checkForAutoPasteValues(personalOfficeEmail);
    personalOfficeEmail.blur(function(){
        isInputValueValid(personalOfficeEmail, new RegExp(regs.email));
        controlCheckMark(currentStepBlock, $j(this));
    });
    personalOfficeEmail.on('input',function(){
        isInputValueValidOnInput(personalOfficeEmail, new RegExp(regs.email));
        controlCheckMark(currentStepBlock, $j(this));
    });

    let personalOfficePhoneNumber = $j('.personal-office-phone').find('input');
    if (personalOfficePhoneNumber.val().length == 10 && personalOfficePhoneNumber.val().startsWith('7')){
        let correctPhone = '7' + personalOfficePhoneNumber.val();
        personalOfficePhoneNumber.val(correctPhone);
    }

    personalOfficePhoneNumber.mask('+7 900 000 00 00');
    checkForAutoPasteNumericValues(personalOfficePhoneNumber);
    checkInputLength(personalOfficePhoneNumber, 16);

    personalOfficePhoneNumber.blur(function(){
        validateJQueryElement(personalOfficePhoneNumber, regs.phone);
        checkInputLengthOnInput(personalOfficePhoneNumber, 16);
        controlCheckMark(currentStepBlock, $j(this));
    });

    personalOfficePhoneNumber.on('input',function(){
        validateJQueryElementOnInput(personalOfficePhoneNumber, regs.phone);
        checkInputLengthOnInput(personalOfficePhoneNumber, 16);
        controlCheckMark(currentStepBlock, $j(this));
    });

    $j('.checkbox-executive').find('input').change(function() {
        var currentStepBlock = $j('.legal-details');
        var sparkExecutive = $j('.executive-spark .spark-executive').text().trim().split(', ');
        var name = $j('.executive-name').find('input');
        var position = $j('.executive-position').find('input');
        if($j('.checkbox-executive').find('input').is(':checked') == true) {
            var executiveName = sparkExecutive[0];
            var executivePosition = sparkExecutive[1];
            name.val(executiveName);
            position.val(executivePosition);
            validateLegalDetails();
            isInputValueValid(name, new RegExp(regs.letters));
            isInputValueValid(position, new RegExp(regs.letters));
            controlCheckMark(currentStepBlock, $j(this));
        } else {
            name.val('');
            position.val('');
            validateLegalDetails();
            isInputValueValid(name, new RegExp(regs.letters));
            isInputValueValid(position, new RegExp(regs.letters));
            controlCheckMark(currentStepBlock, $j(this));
        }
    });

    validateAddressInformation($j('.post-address'));
    validateAddressInformation($j('.legal-address-block'));
}

function validateLegalDetails(){
    var currentStepBlock = $j('.legal-details');

    var isSoleProprietor = $j('[id$=isSoleProprietor]').val();

    var ogrn = $j('.ogrn').find('input');
    var ogrnip = $j('.ogrnip').find('input');
    var kpp = $j('.kpp').find('input');
    var okpo = $j('.okpo').find('input');
    var legalAddress = $j('.legal-address-block');
    var documentAddress = $j('.post-address');
    var executiveName = $j('.executive-name').find('input');
    var executivePosition = $j('.executive-position').find('input');
    var codeWord = $j('.code-word').find('input');
    var personalOfficeEmail = $j('.personal-office-email').find('input');
    let personalOfficePhoneNumber = $j('.personal-office-phone').find('input');

    var isValid = false;
    var validatedFields = [];
    if(isSoleProprietor == 'false'){
        validatedFields.push(isLegalInputValueValid(ogrn, new RegExp(regs.numbers), 13, false));
    }
    if(isSoleProprietor == 'true'){
        validatedFields.push(isLegalInputValueValid(ogrnip, new RegExp(regs.numbers), 15, false));
    }
    validatedFields.push(validateJQueryElement(okpo, regs.okpo));
    if(isSoleProprietor == 'false'){
    validatedFields.push(isLegalInputValueValid(kpp, new RegExp(regs.numbers), 9, false));
    }
    validatedFields.push(isInputValueValid(legalAddress.find('textarea'), new RegExp(regs.address)));
    validatedFields.push(validateAddressInformation(legalAddress));
    validatedFields.push(isInputValueValid(documentAddress.find('textarea'), new RegExp(regs.address)));
    validatedFields.push(validateAddressInformation(documentAddress));
    if(isSoleProprietor == 'false'){
        validatedFields.push(isInputValueValid(executiveName, new RegExp(regs.letters)));
        validatedFields.push(isInputValueValid(executivePosition, new RegExp(regs.position)));
    }
    validatedFields.push(isCodeWordValueValid(codeWord, new RegExp(regs.codeWord)));
    validatedFields.push(isInputValueValid(personalOfficeEmail, new RegExp(regs.email)));
    validatedFields.push(validateJQueryElement(personalOfficePhoneNumber, regs.phone));
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    var checkMark = currentStepBlock.find('.checkmark');
    if(isValid){
        currentStepBlock.addClass('done');
        checkMark.show();
    } else {
        currentStepBlock.removeClass('done');
        checkMark.hide();
    }
}

function isLegalInputValueValid(element, regex, numberOfSymbols, isOkpo){
    var isValid = false;
    var elementValue = element.val();
    var elementLength = elementValue.length;
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if (isOkpo) {
            if((elementLength === numberOfSymbols) || (elementLength === (numberOfSymbols - 2))){
                element.removeClass('error');
                element.addClass('valid');
                isValid = true;
            } else {
                element.removeClass('valid');
                element.addClass('error');
                isValid = false;
            }
        } else {
            if(elementLength === numberOfSymbols) {
                element.removeClass('error');
                element.addClass('valid');
                isValid = true;
            } else {
                element.removeClass('valid');
                element.addClass('error');

                isValid = false;
            }
        }
    } else {
        element.removeClass('valid');
        element.addClass('error');

        isValid = false;
    }
    return isValid;
}

function validateJQueryElement(jQueryElement, pattern) {
    if (jQueryElement != null && pattern != null) {
        if (new RegExp(pattern).test(jQueryElement.val())) {
            jQueryElement.removeClass('error');
            jQueryElement.addClass('valid');
            return true;
        } else {
            jQueryElement.removeClass('valid');
            jQueryElement.addClass('error');
            return false;
        }
    } else {
        return null;
    }
}

function validateJQueryElementOnInput(jQueryElement, pattern) {
    if (jQueryElement != null && pattern != null) {
        if (new RegExp(pattern).test(jQueryElement.val())) {
            jQueryElement.removeClass('error');
            jQueryElement.addClass('valid');
            return true;
        } else {
            jQueryElement.removeClass('valid');
            return false;
        }
    } else {
        return null;
    }
}

function isLegalInputValueValidOnInput(element, regex, numberOfSymbols, isOkpo){
    var isValid = false;
    var elementValue = element.val();
    var elementLength = elementValue.length;
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if (isOkpo) {
            if((elementLength === numberOfSymbols) || (elementLength === (numberOfSymbols - 2))){
                element.removeClass('error');
                element.addClass('valid');
                isValid = true;
            } else {
                element.removeClass('valid');
                isValid = false;
            }
        } else {
            if(elementLength === numberOfSymbols) {
                element.removeClass('error');
                element.addClass('valid');
                isValid = true;
            } else {
                element.removeClass('valid');
                isValid = false;
            }
        }
    } else {
        element.removeClass('valid');
        isValid = false;
    }
    return isValid;
}

function isCodeWordValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    var elementLength = elementValue.length;
    if((elementLength > 4 && elementLength < 21) && regex.test(elementValue)){
        element.removeClass('error');
        element.addClass('valid');
        isValid = true;
    } else {
        element.removeClass('valid');
        element.addClass('error');
        isValid = false;
    }
    return isValid;
}
// ----- END Legal Details ----- //

// ----- Payment Details ----- //
function setEvents_paymentDetails(){
    var currentStepBlock = $j('.payment-details');

    validatePaymentDetails();

    var bik = $j('.bank-bic').find('input');
    checkForAutoPasteNumericValues(bik);
    bik.blur(function(e){
        isLegalInputValueValid(bik, new RegExp(regs.numbers), 9, false);
        controlCheckMark(currentStepBlock, $j(this));
    });
    bik.on('input',function(){
        isLegalInputValueValid(bik, new RegExp(regs.numbers), 9, false);
        controlCheckMark(currentStepBlock, $j(this));
    });

    var checkingAccount = $j('.checking-account').find('input');
    checkForAutoPasteNumericValues(checkingAccount);
    checkingAccount.blur(function(e){
        isLegalInputValueValid(checkingAccount, new RegExp(regs.numbers), 20, false);
        controlCheckMark(currentStepBlock, $j(this));
    });
    checkingAccount.on('input',function(){
        isLegalInputValueValid(checkingAccount, new RegExp(regs.numbers), 20, false);
        controlCheckMark(currentStepBlock, $j(this));
    });

    var corAccount = $j('.cor-account').find('input');
    checkForAutoPasteNumericValues(corAccount);
    corAccount.blur(function(e){
        isLegalInputValueValid(corAccount, new RegExp(regs.numbers), 20, false);
        controlCheckMark(currentStepBlock, $j(this));
    });
    corAccount.on('input',function(){
        isLegalInputValueValid(corAccount, new RegExp(regs.numbers), 20, false);
        controlCheckMark(currentStepBlock, $j(this));
    });

    var prepayment = $j('.prepay-amount').find('input');
    checkForAutoPasteNumericValues(prepayment);
    prepayment.blur(function(e){
        isPrepaymentAmountValueValid(prepayment, new RegExp(regs.numbers));
        controlCheckMark(currentStepBlock, $j(this));
    });
    prepayment.on('input',function(){
        isPrepaymentAmountValueValid(prepayment, new RegExp(regs.numbers));
        controlCheckMark(currentStepBlock, $j(this));
    });
}

function validatePaymentDetails(){
    var currentStepBlock = $j('.payment-details');
    var bank = $j('.bank-short-name').find('input');
    var bic = $j('.bank-bic').find('input');
    var checkingAccount = $j('.checking-account').find('input');
    var corAccount = $j('.cor-account').find('input');
    var prepayAmount = $j('.prepay-amount').find('input');
    var isValid = false;
    var validatedFields = [];

    var isBankDataInvalid = getValidityOfBankData(bank.val(), bic.val(), corAccount.val());

    validatedFields.push(isInputValueValid(bank, new RegExp(regs.bankName)));
    validatedFields.push(isLegalInputValueValid(bic, new RegExp(regs.numbers), 9, false));
    validatedFields.push(isLegalInputValueValid(checkingAccount, new RegExp(regs.numbers), 20, false));
    validatedFields.push(isLegalInputValueValid(corAccount, new RegExp(regs.numbers), 20, false));
    validatedFields.push(isPrepaymentAmountValueValid(prepayAmount, new RegExp(regs.numbers)));
    validatedFields.push(!isBankDataInvalid);

    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    $j('[id$=bankInformationInvalid]').val(isBankDataInvalid);

    var checkMark = currentStepBlock.find('.checkmark');
    if(isValid){
        currentStepBlock.addClass('done');
        checkMark.show();
    } else {
        currentStepBlock.removeClass('done');
        checkMark.hide();
    }
}

function isPrepaymentAmountValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    if((elementValue >= 2000 && elementValue <= 9999999) && regex.test(elementValue)){
        element.removeClass('error');
        element.addClass('valid');
        isValid = true;
        element.parent().find('.validation-result').remove();
    } else {
        element.removeClass('valid');
        element.addClass('error');
        isValid = false;
        if (!element.parent().find('.validation-result').is(':visible')){
            element.parent().append('<div class="validation-result">Минимальная сумма Инициирующего платежа от 2000 р.</div>');
        }
    }
    return isValid;
}
// ----- END Payment Details ----- //


// ----- Utils Methods ----- //
function validateStepsDone(sOpportunityId, sFormDataId){
    var formBlock = $j('.b-form');
    var isValid = false;
    var contactDetails = $j('.contact-details');
    var companyDetails = $j('.company-details');
    var orderDetails = $j('.tariffs');
    var legalDetails = $j('.legal-details');
    var paymentDetails = $j('.payment-details');
    isValid = (contactDetails.hasClass('done') &&
               orderDetails.hasClass('done') &&
               legalDetails.hasClass('done') &&
               paymentDetails.hasClass('done')) ? true : false;
    if(isValid) {
        if ($j('div').is('.virtual-cards')) {
            if ($j('.virtual-cards').find('input').prop('checked')) {
                if (confirm('Клиенту будет подключен PPR Pay, в заказе будет только виртуальные карты. Физические Карты можно заказать в ЛК. Продолжить?')) {
                    processData();
                }
            } else {
                processData();
            }
        } else {
            processData();
        }
    } else {
        alert('Не все данные заполнены. Проверьте корректность заполненных данных.');
    }
};

function validateStepsForPreview() {
    var formBlock = $j('.b-form');
    var isValid = false;
    var contactDetails = $j('.contact-details');
    var companyDetails = $j('.company-details');
    var orderDetails = $j('.tariffs');
    var legalDetails = $j('.legal-details');
    var paymentDetails = $j('.payment-details');
    isValid = (contactDetails.hasClass('done') &&
               orderDetails.hasClass('done') &&
               legalDetails.hasClass('done') &&
               paymentDetails.hasClass('done')) ? true : false;
    if(isValid){
        previewContract();
    } else {
        alert('Не все данные заполнены. Проверьте корректность заполненных данных.');
    }
}

function validateForm(){
    var phoneNumber = $j('.contact-phone').find('input');
    var emailAddress = $j('.contact-email').find('input');
    var fullName = $j('.contact-name').find('input');

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(phoneNumber, new RegExp(regs.phone)));
    validatedFields.push(isInputValueValid(emailAddress, new RegExp(regs.email)));
    validatedFields.push(isInputValueValid(fullName, new RegExp(regs.letters)));
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    if(isValid){
        saveSObjects();
    } else {
        alert('Информация не может быть сохранена без указания ФИО, телефона и email контактного лица');
    }
};

function postCheckForm(){
    validateContactDetails();
    validateCompanyDetails();
    validateOrder();
    validateLegalDetails();
    validateAddressInformation($j('.post-address'));
    validateAddressInformation($j('.legal-address-block'));
    validatePaymentDetails();
    var buttonProcess = $j('.btn.process');
    buttonProcess.addClass('disabled');
}

function checkFinalResponse(){
    var currentStepBlock = $j('.final');
    var mzkNumber = $j('.mzk-request .data').text().trim();
    var transitOpportunityId = $j('.transit-cont-id .data').text().trim();

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(mzkNumber != '' ? true : false);
    validatedFields.push(transitOpportunityId != '' ? true : false);
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    var checkMark = currentStepBlock.find('.checkmark');
    var buttonProcess = $j('.btn.process');
    if(isValid){
        buttonProcess.addClass('disabled');
        currentStepBlock.addClass('done');
        checkMark.show();
    }
};

function controlCheckMark(block, input){
    var inputs = block.find('input');
    var hasBlockError = false;
    block.addClass('done');
    inputs.each(function() {
        if($j(this).hasClass('error')){
            block.removeClass('done');
            hasBlockError = true;
            return;
        }
    });
    var areaInputs = block.find('textarea');
    areaInputs.each(function() {
        if($j(this).hasClass('error')){
            block.removeClass('done');
            hasBlockError = true;
            return;
        }
    });

    var hasData = block.hasClass('has-data');
    var isBlockDone = block.hasClass('done');
    var checkMark = block.find('.checkmark');
    var isCompanyDetailsBlock = block.hasClass('company-details');
    if(isCompanyDetailsBlock){
        if(!hasBlockError && isBlockDone && hasData){
            checkMark.show();
        } else {
            checkMark.hide();
        }
    } else {
        if(!hasBlockError && isBlockDone){
            checkMark.show();
        } else {
            checkMark.hide();
        }
    }
}

function checkForAutoPasteNumericValues(block){
    $j(block).bind('paste', function(event) {
        var self = this;
        var origin = $j(self).val();
        setTimeout(function() {
            var val = $j(self).val();
            if($j.isNumeric(val)){
            } else {
                 $j(block).val(origin);
            }
        }, 0);
    });
}

function checkForAutoPasteValues(block, regex){
    $j(block).bind('paste', function(event) {
        var self = this;
        var origin = $j(self).val();
        setTimeout(function() {
            var val = $j(self).val();
            if(regex.test(val)){
            } else {
                 $j(block).val(origin);
            }
        }, 0);
    });
}

function checkInputLength(input, inputLength){
    input.blur(function(){
        if(input.val().length != inputLength) {
            input.addClass('error').removeClass('valid');
        } else {
            input.addClass('valid').removeClass('error');
        }
    });
}

function checkInputLengthOnInput(input, inputLength){
    if(input.val().length != inputLength) {
        input.addClass('error').removeClass('valid');
    } else {
        input.addClass('valid').removeClass('error');
    }
}

function isCheckBoxChecked(element){
    return element.is(':checked');
}

function isInputValueValid(element, regex){
    var isValid = false;
    var elementValue = element.val();
    if((elementValue.trim() != '') && regex.test(elementValue)){
        element.removeClass('error');
        element.addClass('valid');
        isValid = true;
    } else {
        element.removeClass('valid');
        element.addClass('error');
        isValid = false;
    }
    return isValid;
}

function isInputValueValidOnInput(element, regex){
    var isValid = false;
    var elementValue = element.val();
    if((elementValue.trim() != '') && regex.test(elementValue)){
        element.addClass('valid');
        element.removeClass('error');
        isValid = true;
    } else {
        element.removeClass('valid');
        element.addClass('error');
        isValid = false;
    }
    return isValid;
}

function addSplashBlock (block){
     var splashElem =
     '<div class="splash-status" id="splashDiv">' +
          '<div class="loader"></div>' +
     '</div>';
     block.append(splashElem);
}

function removeSplashBlock (block){
    block.find('[id$=splashDiv]').remove();
}
// ----- END Utils Methods ----- //

// ----- Remote Actions ----- //
function request(sOpportunityId, sFormDataId, needUpdate) {
    var currentBlock = $j('.company-details');
    var isSole = false;
    var companyDataFromSpark = $j('[id$=companyNameSpark]').text().trim();
    var companyInn = $j('[id$=companyInn]').text().trim();
    var logInn = $j('[id$=formDataInn]').val();

        startSplash(currentBlock);
    if(logInn == '' || companyInn == logInn){ // if form data already has spark data for the same INN
        var opportunityId = sOpportunityId;
        var formDataId = sFormDataId;
        if(companyInn.length == 10) {
            isSole = false;
            $j('[id$=isSoleProprietor]').val(false);
            getCompanyData(window, companyInn, isSole, opportunityId, sFormDataId, needUpdate);
        } else if(companyInn.length == 12){
            isSole = true;
            $j('[id$=isSoleProprietor]').val(true);
            getEntrepreneurData(window, companyInn, isSole, opportunityId, sFormDataId, needUpdate);
        } else {
            endSplash();
            $j('.check-message').text('Некорректный формат ИНН. Длина ИНН должна быть 10 символов для Юр. лица и 12 для ИП');
        }
    } else {
        endSplash();
        $j('.check-message').text('У компании был изменен ИНН. Просьба обратиться к администратору.');
    }
}

function getCompanyData(window, companyInn, isSole, opportunityId, formDataId, needUpdate) {
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.remoteGetCompanyData, companyInn,
        function(data, event) {
            if (event.status) {
                if(data != null){
                $j('[id$=companyInfoSpark]').val(JSON.stringify(data));
                var companyFullName = data != null ? data.fullName.replace(/&quot;/g, '"') : '';
                $j('[id$=companyNameSpark]').text(companyFullName);
                    $j('.ogrn').find('input').val(data.ogrn);
                    $j('.kpp').find('input').val(data.extendedReport.kpp);
                    $j(".okpo").find("input").val(data.okpo);
                    $j(".okpo").find("input").attr("disabled", new RegExp(regs.okpo).test(data.okpo));
                    $j('.legal-address-block').find('textarea').val(data.address);
                    if(data.extendedReport.leaderList.leader.length > 0){
                        $j('.executive-spark .spark-executive').text(data.extendedReport.leaderList.leader[0].fio + ', '
                                                                   + data.extendedReport.leaderList.leader[0].position);
                    }
                    validateLegalDetails();
                    if(needUpdate == true){
                remoteUpdateCompanySparkInfo(JSON.stringify(data), formDataId, opportunityId, companyInn);
                remoteCreateEmployee(formDataId, JSON.stringify(data.extendedReport.leaderList));
                    } else {
                        $j('[id$=companySpark]').val(JSON.stringify(data));
                    }
                checkCompany(window, isSole, opportunityId, formDataId);
            } else {
                    endSplash();
                    $j('.check-message').text('Не удалось найти данные по компании с указанным ИНН в СПАРК.');
                }
            } else {
                console.debug(event.message + '<br/>\n<pre>' + event.where + '</pre>');
            }
       },
        {buffer: false, escape: true}
    );
};

function getEntrepreneurData(window, companyInn, isSole, opportunityId, formDataId, needUpdate){
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.remoteGetEntrepreneurData,
        companyInn,
        function(data, event){
            if (event.status) {
                if(data != null){
                $j('[id$=soleInfoSpark]').val(JSON.stringify(data));
                    if(data.fullNameRus == null){
                        endSplash();
                        $j('.check-message').text('Не удалось найти данные по компании с указанным ИНН в СПАРК.');
                    }
                var companyFullName = data != null ? 'ИП ' + data.fullNameRus.replace(/&quot;/g, '"') : '';
                $j('[id$=companyNameSpark]').text(companyFullName);
                    $j('.ogrnip').find('input').val(data.ogrnip);
                    $j('.okpo').find('input').val(data.okpo);
                    $j(".okpo").find("input").attr("disabled", new RegExp(regs.okpo).test(data.okpo));
                    validateLegalDetails();
                    if(needUpdate == true){
                updateEntrepreneurShortReportData(JSON.stringify(data), formDataId);
                    } else {
                        $j('[id$=soleSpark]').val(JSON.stringify(data));
                    }
                    checkCompany(window, isSole, opportunityId, formDataId, needUpdate);
            } else {
                    endSplash();
                    $j('.check-message').text('Не удалось найти данные по компании с указанным ИНН в СПАРК.');
                }
            } else {
                console.debug(event.message + '<br/>\n<pre>' + event.where + '</pre>');
            }
        },
        {buffer: false, escape: true}
    );
};

function checkValidationData(dataValue, decisionType, decision){
    var buttonProcess = $j('.btn.process');
    if (decisionType === decisionTypes[0]) {
        if (!approvalProcessRMDActive && decision == 1) {
            buttonProcess.addClass('disabled');
            dataValue.addClass('refused');
            alert('Компания не может быть поставлена на старт необходимо согласование с ОУР. '
                    + 'Обратитесь к Вашему менеджеру или администратору.');
        } else if (decision == 3) {
            buttonProcess.addClass('disabled');
            dataValue.addClass('refused');
            alert('Компания не может быть поставлена на старт - Отказ по ЧЧС. '
                    + 'Обратитесь к Вашему менеджеру или администратору.');
        } else if (!approvalProcessRMDActive && decision == 4) {
            buttonProcess.addClass('disabled');
            dataValue.addClass('refused');
            alert('Компания не может быть поставлена на старт необходимо согласование Перекупщика. '
                    + 'Обратитесь к Вашему менеджеру или администратору.');
        } else {
            // buttonProcess.removeClass('disabled');
            dataValue.removeClass('refused');
        }
    } else if(decisionType === decisionTypes[1]){
        if(decision == 2){
            buttonProcess.addClass('disabled');
            dataValue.addClass('refused');
            alert('Компания не может быть поставлена на старт по решению Скоринга. '
                    + 'За уточнением братитесь к Вашему менеджеру или администратору.');
        } else {
            // buttonProcess.removeClass('disabled');
            dataValue.removeClass('refused');
        }
    }
};

function checkCompany(window, isSole, opportunityId, formDataId, needUpdate){
    var companyInfo = '';
    if(isSole == true) {
        companyInfo = $j('[id$=soleInfoSpark]').val();
    } else {
        companyInfo = $j('[id$=companyInfoSpark]').val();
    }
    if(companyInfo != ''){
        var company = JSON.parse(companyInfo);
        var companyInn = company.inn;
        var companySparkId = company.sparkID;
        Visualforce.remoting.Manager.invokeAction(
            window.configSettings.remoteActions.checkCompany,
            isSole, companyInn, companySparkId, opportunityId,
            function(verification, event){
                if (event.status) {
                    if(verification != null){
                        getVerificationResult(window, isSole, companyInn, companySparkId, opportunityId, formDataId, verification, needUpdate);
                        updateVerifiedDecision(window, formDataId, opportunityId, companyInn, verification);
                        $j('[id$=verification]').val(JSON.stringify(verification));
                        var dataValue = $j('.verified-decision .data');
                        checkValidationData(dataValue, decisionTypes[0], verification.decision);
                    }
                } else {
                    console.debug(event.message + '<br/>\n<pre>' + event.where + '</pre>');
                }
            },
            {buffer: false, escape: true}
        );
    }
};

function getVerificationResult(window, isSole, companyInn, companySparkId, opportunityId, formDataId, verification, needUpdate){
    var currentBlock = $j('.company-details');
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.getVerification,
        verification,
        function(result, event){
            if (event.status) {
                $j('[id$=verifiedDecision]').text(result);
                $j('[id$=verifiedLimitation]').text(verification.limitation);
                if (isSole == false) {
                    getScoreDecision(window, companyInn, companySparkId, opportunityId, formDataId, JSON.stringify(verification), needUpdate);
                } else {
                    validateCompanyDetails();
                    endSplash();
                }
            } else {
                console.debug(event.message + '<br/>\n<pre>' + event.where + '</pre>');
            }
        },
        {buffer: false, escape: true}
    );
};

function getScoreDecision(window, inn, sparkId, opportunityId, formDataId, verificationDecision, needUpdate){
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.getScore,
        inn, sparkId, opportunityId, verificationDecision,
        function(decision, event){
            if (event.status) {
                if(decision != null){
                    if (decision.decision == 0) {
                        allowPaidOverdraft = true;
                        $j('.paid-overdraft').show();
                    }
                    getDecisionResult(window, decision);
                    updateScoreDecision(window, formDataId, opportunityId, JSON.stringify(decision));
                    $j('[id$=decision]').val(JSON.stringify(decision));
                    var dataValue = $j('.scoring-decision .data');
                    checkValidationData(dataValue, decisionTypes[1], decision.decision);
                } else {
                    endSplash();
                }
            } else {
                console.debug(event.message + '<br/>\n<pre>' + event.where + '</pre>');
            }
        },
        {buffer: false, escape: true}
    );
};

function getDecisionResult(window, decision){
    var currentBlock = $j('.company-details');
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.getDecision,
        decision,
        function(result, event){
            if (event.status) {
                 $j('[id$=scoringDecision]').text(result);
                 var today = new Date();
                 today.setMonth(today.getMonth() + 1); // get current month
                 var scoringDate = parseDateToString(today, 'dd.MM.yyyy');
                 today.setMonth(today.getMonth() + 3); // add three months
                 var scoringExpirationDate = parseDateToString(today, 'dd.MM.yyyy');
                 $j('[id$=scoringDate]').text(scoringDate);
                 $j('[id$=scoringExpirationDate]').text(scoringExpirationDate);
                 var currentBlock = $j('.company-details');
                 currentBlock.addClass('has-data');
                 validateCompanyDetails();
                 endSplash();
            } else {
                console.debug(event.message + '<br/>\n<pre>' + event.where + '</pre>');
            }
        },
        {buffer: false, escape: true}
    );
};

function parseDateToString(date, format){
    var dateString = (date.getDate() + '.' + ('0' + (date.getMonth())).slice(-2) + '.' + date.getFullYear()).toString(format);
    return dateString;
};

function remoteUpdateCompanySparkInfo(companySparkInfo, formDataId, opportunityId, companyInn) {
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.remoteUpdateCompanySparkInfo,
        companySparkInfo, formDataId, opportunityId, companyInn,
        function(result, event){
            if (event.status) {
                updateCreditListAndSection();
            } else {
                console.debug(event.message + "<br/>\n<pre>" + event.where + "</pre>");
            }
        }
    );
};

function updateEntrepreneurShortReportData(soleInfoSpark, formDataId) {
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.remoteUpdateEntrepreneurShortReport,
        soleInfoSpark, formDataId,
        function(result, event){
            if (event.status) {
            } else {
                console.debug(event.message + "<br/>\n<pre>" + event.where + "</pre>");
            }
        }
    );
};

function remoteCreateEmployee(formDataId, leaderList) {
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.remoteCreateExecutiveEmployee,
        formDataId, leaderList,
        function(result, event){
            if (event.status) {
                $j('[id$=executiveId]').val(result);
            } else {
                console.debug(event.message + "<br/>\n<pre>" + event.where + "</pre>");
            }
        }
    );
};

function updateVerifiedDecision(window, formDataId, opportunityId, companyInn, verification){
    Visualforce.remoting.Manager.invokeAction(
    window.configSettings.remoteActions.updateVerifiedDecision,
    formDataId, opportunityId, companyInn, JSON.stringify(verification),
       function(result, event){
           if (event.status) {
           } else {
               console.debug(event.message + "<br/>\n<pre>" + event.where + "</pre>");
           }
       }
    );
};

function updateScoreDecision(window, formDataId, opportunityId, verificationDecision) {
    Visualforce.remoting.Manager.invokeAction(
        window.configSettings.remoteActions.updateScoreDecision,
        formDataId, opportunityId, verificationDecision,
        function(decision, event){
            if (event.status) {
            } else {
                console.debug(event.message + "<br/>\n<pre>" + event.where + "</pre>");
            }
        }
    );
};


// *** DADATA *** //

function dadataBank(){
    var searchBankBlock = $j('.bankName').parent();
    if (!searchBankBlock.find('.bank-name-list')[0]){
     searchBankBlock.append('<div class="bank-name-list"></div>');
         $j('.bank-name-list').slideUp();
    }

    $j('.bankName').on('input',function(e){
    var textQuery =  $j('.bankName').val();
    if (textQuery != ''){
        sendRequestToDadata('bank', textQuery, 'searchBank');
    }
    else {
        formResultList(null,'searchBank');
    }
        saveBankInformation('','','','');
    });

    $j('body').on('click','.bank-name-item' , function(event) {
        $j('.bank-name-list').slideUp();
        $j('.bankName').val($j(this).find('strong').text());
        $j('.bankBic').val($j(this).data('bic'));
        $j('.corBankAccount').val($j(this).data('kc'));
        saveBankInformation($j(this).data('name-short'),
                            $j(this).data('okpo'),
                            $j(this).data('town'),
                            $j(this).data('address'));
        validatePaymentDetails();
    });

    $j('.bankName').on('focusout', function (event) {
        $j('.bank-name-list').slideUp();
        $j('.bankName').val($j(this).find('strong').text());
        $j('.bankBic').val($j(this).data('bic'));
        $j('.corBankAccount').val($j(this).data('kc'));
        saveBankInformation($j(this).data('name-short'),
            $j(this).data('okpo'),
            $j(this).data('town'),
            $j(this).data('address'));
        validatePaymentDetails();
    });

    $j(document).mouseup(function (e) {
        var containers = $j('.bank-name-list');
        if (containers.has(e.target).length === 0){
            containers.slideUp();
        }
    });

    $j('.bank-name-list').mCustomScrollbar({
        theme:'dark'
    });
}

function saveBankInformation(shortName, okpo, bankTown, bankAddress){
    $j('[id$=bankInformationShortName]').val(shortName);
    $j('[id$=bankInformationOKPO]').val(okpo);
    $j('[id$=bankInformationTown]').val(bankTown);
    $j('[id$=bankInformationAddress]').val(bankAddress);
}

function getValidityOfBankData(bankName, bankBIC, bankKC){
    var bankInformationInvalid = true;
    if (!apiTokenDaData || apiTokenDaData === '') {
        return bankInformationInvalid;
    }

    var xhttp = new XMLHttpRequest();
    xhttp.open('POST', 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/bank', false);
    xhttp.setRequestHeader('Content-type', 'application/json');
    xhttp.setRequestHeader('Accept', 'application/json');
    xhttp.setRequestHeader('Authorization', 'Token ' + apiTokenDaData);
    xhttp.send('{ "query": "' + bankBIC + '" }');
    var response = JSON.parse(xhttp.responseText);
    var suggestions = response.suggestions;
    if(suggestions.length > 0){
        if( bankName == suggestions[0].data.name.payment &&
            bankBIC == suggestions[0].data.bic &&
            bankKC == suggestions[0].data.correspondent_account ) {
                bankInformationInvalid = false;
    }
    var bankTown = '';
    if(suggestions[0].data.address.data != null) {
        bankTown = suggestions[0].data.address.data.city_with_type;
    } else {
        //SF-971
        bankTown = suggestions[0].data.payment_city;
    }
    var bankNameShort = suggestions[0].data.name.short;
    if(bankNameShort == null){
        bankNameShort = suggestions[0].data.name.payment;
    }
    //SF-799
    saveBankInformation(bankNameShort,
                        suggestions[0].data.okpo,
                        bankTown,
                        suggestions[0].data.address.value
    );
    }
    return bankInformationInvalid;
}

function validateAddressInformation(address){
    var isValid = true;
    var notValidValue;
    //VS SF-579
    if( !address.prop('disabled') ){
        if(address.hasClass('post-address')){
            if($j('.checkbox-address').find('input').is(':checked') == false) {
                /*if($j('[id$=postalAddressInformationCity]').val() == '')       { isValid = false; }
                if($j('[id$=postalAddressInformationPostalCode]').val() == '') { isValid = false; }
                if($j('[id$=postalAddressInformationState]').val() == '')      { isValid = false; }
                if($j('[id$=postalAddressInformationStreet]').val() == '')     { isValid = false; }*/
                if($j('[id$=postalAddressInformationHouse]').val() == '')      { isValid = false; }
                notValidValue = 'Неверный адрес для доставки документов. Введите корректный адрес или выберите адрес из списка.';
            }
        } else if (address.hasClass('legal-address-block')){
            if ($j('[id$=isSoleProprietor]').val()  == 'true') {
                /*if($j('[id$=legalAddressInformationCity]').val() == '')       { isValid = false; }
                if($j('[id$=legalAddressInformationPostalCode]').val() == '') { isValid = false; }
                if($j('[id$=legalAddressInformationState]').val() == '')      { isValid = false; }
                if($j('[id$=legalAddressInformationStreet]').val() == '')     { isValid = false; }*/
                if($j('[id$=legalAddressInformationHouse]').val() == '')      { isValid = false; }
                notValidValue = 'Неверный юридический адрес. Введите корректный адрес или выберите адрес из списка.';
            }
        }

        if(isValid){
            address.find('.validation-result').remove();
            address.find('textarea').addClass('valid');
            address.find('textarea').removeClass('error');
        } else {
            if (!address.find('.validation-result').is(':visible')){
                address.append('<div class="validation-result">' + notValidValue + '</div>');
            }
            address.find('textarea').removeClass('valid');
            address.find('textarea').addClass('error');
        }
    }
    return isValid;
}

// ADDRESSES
function dadataDocumentAddress(){
    var searchDocumentAddressBlock = $j('.document-address').parent();
    if (!searchDocumentAddressBlock.find('.document-address-list')[0]){
     searchDocumentAddressBlock.append('<div class="document-address-list"></div>');
    }

    $j('.document-address').on('input click',function(e){
    var textQuery =  $j(this).val();
    if (textQuery != ''){
        sendRequestToDadata('address', textQuery, 'searchDocumentAddress');
    }
    else {
        formResultList(null,'searchDocumentAddress');
    }
    if(e.type == 'input'){
        if($j('.checkbox-address').find('input').is(':checked') == true) {
            $j('.checkbox-address').find('input').prop('checked', false)
        }
        saveAddressInformation('postalAddress','','','','','');
            $j('.post-address').find('.validation-result').remove();
    }
        if(e.type == 'click'){
            validateAddressInformation($j('.post-address'));
        }
    });

    $j('body').on('click','.document-address-item' , function(event) {
        if($j('.checkbox-address').find('input').is(':checked') == true) {
            $j('.checkbox-address').find('input').prop('checked', false)
        }
        $j('.document-address-list').slideUp();
        $j('.document-address').val($j(this).find('strong').text());
        saveAddressInformation('postalAddress',
                            $j(this).data('city'),
                            $j(this).data('postal_code'),
                            $j(this).data('region'),
                            $j(this).data('street'),
                            $j(this).data('house'),
                            $j(this).data('flat'));
        validateAddressInformation($j('.post-address'));
        validateLegalDetails();
    });

    $j(document).mouseup(function (e) {
        if ($j('.document-address-item').is(':visible')){
            if ($j('.document-address-list').has(e.target).length === 0){
                $j('.document-address-list').slideUp();
                var addressIsSelected = false;
                $j('.document-address-item').each(function( index ) {
                    if($j(this).find('strong').text() == $j('.document-address').val()){
                        addressIsSelected = true;
                    }
                })
                if(!addressIsSelected  && $j('.document-address-item').length != 0){
                    var firstDocumentAddressItem = $j('.document-address-item').first();
                    $j('.document-address').val(firstDocumentAddressItem.find('strong').text());
                    saveAddressInformation('postalAddress',
                                            firstDocumentAddressItem.data('city'),
                                            firstDocumentAddressItem.data('postal_code'),
                                            firstDocumentAddressItem.data('region'),
                                            firstDocumentAddressItem.data('street'),
                                            firstDocumentAddressItem.data('house'),
                                            firstDocumentAddressItem.data('flat'));
                    validateAddressInformation($j('.post-address'));
                    validateLegalDetails();
                }
                validateLegalDetails();
            }
        }
    });

    $j('.document-address-list').mCustomScrollbar({
    theme:'dark'
    });
}

function saveAddressInformation(addressType, city, postal_code, region, street, house, flat){
    //VS SF-579
    if(addressType == 'postalAddress'){
        $j('[id$=postalAddressInformationCity]').val(city);
        $j('[id$=postalAddressInformationPostalCode]').val(postal_code);
        $j('[id$=postalAddressInformationState]').val(region);
        $j('[id$=postalAddressInformationStreet]').val(street);
        $j('[id$=postalAddressInformationHouse]').val(house);
        $j('[id$=postalAddressInformationFlat]').val(flat);
    } else if (addressType == 'legalAddress'){
        $j('[id$=legalAddressInformationCity]').val(city);
        $j('[id$=legalAddressInformationPostalCode]').val(postal_code);
        $j('[id$=legalAddressInformationState]').val(region);
        $j('[id$=legalAddressInformationStreet]').val(street);
        $j('[id$=legalAddressInformationHouse]').val(house);
        $j('[id$=legalAddressInformationFlat]').val(flat);
    }
}

/* DOCUMENT ADDRESS */
function dadataLegalAddress(){
    /* Legal address search START */
    var legalAddressBlock = $j('.legal-address').parent();
    if (!legalAddressBlock.find('.legal-address-list')[0]){
         legalAddressBlock.append('<div class="legal-address-list"></div>');
    }

    $j('.legal-address').on('input click',function(e){
        var textQuery =  $j(this).val();
        if (textQuery != ''){
            sendRequestToDadata('address', textQuery, 'searchLegalAddress');
        } else {
            formResultList(null,'searchLegalAddress');
        }
        if(e.type == 'input'){
            saveAddressInformation('legalAddress','','','','','');
                $j('.legal-address-block').find('.validation-result').remove();
        }
        if(e.type == 'click'){
            validateAddressInformation($j('.legal-address-block'));
        }
    });

    $j('.legal-address-add').find('input').on('input click',function(e){
         if($j('.checkbox-address').find('input').is(':checked') == true){
             $j('.post-address-add').find('input').val($j('.legal-address-add').find('input').val());
     }
    });

    $j('.checkbox-address').find('input').change(function() {
        var currentStepBlock = $j('.legal-details');
        if($j('.checkbox-address').find('input').is(':checked') == true) {
            $j('.document-address').val($j('.legal-address').val());
            saveAddressInformation('postalAddress',
                                   $j('[id$=legalAddressInformationCity]').val(),
                                   $j('[id$=legalAddressInformationPostalCode]').val(),
                                   $j('[id$=legalAddressInformationState]').val(),
                                   $j('[id$=legalAddressInformationStreet]').val(),
                                   $j('[id$=legalAddressInformationHouse]').val(),
                                   $j('[id$=legalAddressInformationFlat]').val());
            isInputValueValid($j('.document-address'), new RegExp(regs.address));
            validateAddressInformation($j('.post-address'));
            controlCheckMark(currentStepBlock, $j(this));
            $j('.post-address-add').find('input').val($j('.legal-address-add').find('input').val());
        } else {
            $j('.document-address').val('');
            saveAddressInformation('postalAddress','','','','','');
            isInputValueValid($j('.document-address'), new RegExp(regs.address));
            validateAddressInformation($j('.post-address'));
            controlCheckMark(currentStepBlock, $j(this));
            $j('.post-address-add').find('input').val('');
        }
    });

    $j('body').on('click','.legal-address-item' , function(event) {
        $j('.legal-address-list').slideUp();
        $j('.legal-address').val($j(this).find('strong').text());
        saveAddressInformation('legalAddress',
                           $j(this).data('city'),
                           $j(this).data('postal_code'),
                           $j(this).data('region'),
                           $j(this).data('street'),
                           $j(this).data('house'),
                           $j(this).data('flat'));
        validateAddressInformation($j('.legal-address-block'));
        validateLegalDetails();
        if($j('.checkbox-address').find('input').is(':checked') == true){
            $j('.document-address').val($j('.legal-address').val());
            saveAddressInformation('postalAddress',
                               $j(this).data('city'),
                               $j(this).data('postal_code'),
                               $j(this).data('region'),
                               $j(this).data('street'),
                               $j(this).data('house'),
                               $j(this).data('flat'));
            validateAddressInformation($j('.post-address'));
            validateLegalDetails();
        }
    });

    $j(document).mouseup(function (e) {
        if ($j('.legal-address-item').is(':visible')){
            if ($j('.legal-address-list').has(e.target).length === 0){
                $j('.legal-address-list').slideUp();
                var addressIsSelected = false;
                $j('.legal-address-item').each(function( index ) {
                    if($j(this).find('strong').text() == $j('.legal-address').val()){
                       addressIsSelected = true;
                    }
                })
                if(!addressIsSelected && $j('.legal-address-item').length != 0){
                    var firstDocumentAddressItem = $j('.legal-address-item').first();
                    $j('.legal-address').val(firstDocumentAddressItem.find('strong').text());
                    saveAddressInformation('legalAddress',
                                            firstDocumentAddressItem.data('city'),
                                            firstDocumentAddressItem.data('postal_code'),
                                            firstDocumentAddressItem.data('region'),
                                            firstDocumentAddressItem.data('street'),
                                            firstDocumentAddressItem.data('house'),
                                            firstDocumentAddressItem.data('flat'));
                    validateAddressInformation($j('.legal-address-block'));
                }
            }
            validateLegalDetails();
        }
    });

    $j('.legal-address-list').mCustomScrollbar({
    theme:'dark'
    });
}
/* Legal address search END */

// COMMON FUNCTIONS
function sendRequestToDadata(source, query, type) {
    var xhttp = new XMLHttpRequest();
    xhttp.open('POST', ' https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/' + source);
    xhttp.setRequestHeader('Content-type', 'application/json');
    xhttp.setRequestHeader('Accept', 'application/json');
    xhttp.setRequestHeader('Authorization', 'Token ' + apiTokenDaData);
    xhttp.onreadystatechange = function () {
       if (this.readyState === 4 && this.status === 200) {
               var response = JSON.parse(xhttp.responseText);
               formResultList(response, type);
         } else {
             return false;
         }
    };
    query = query.split('"');
    var jsonRequest = '{ "query": "'+ query +'" ';
    jsonRequest += '}';
    if (apiTokenDaData && apiTokenDaData !== '') {
        xhttp.send(jsonRequest);
    }
}

// Form dropdown list
function formResultList(response, type){
     var listName;
     var listItem;
     if (type == 'searchLegalAddress'){
         listName = 'legal-address-list';
         listItem = 'legal-address-item';
     } else if (type == 'searchDocumentAddress'){
         listName = 'document-address-list';
         listItem = 'document-address-item';
     } else if (type == 'searchBank'){
         listName = 'bank-name-list';
         listItem = 'bank-name-item';
     } else {
         return false;
     }

     $j('.' + listName).find('.mCSB_container .' + listItem).remove();
     if (response == null){
         $j('.' + listName).hide();
         $j('.' + listName).closest('.input__obl').removeClass('border-list-input');
         return false;
     } else {
         if (type != 'searchCompany_noShow'){
            $j('.' + listName).show();
            $j('.' + listName).closest('.input__obl').addClass('border-list-input');
         } else {
            type = 'searchCompany';
         }
     }

     var suggestions = response.suggestions;
     for (var i = 0; i < suggestions.length; i++){
         var htmlCodeItem = generateListItem(suggestions[i], type, listItem);
         $j('.' + listName).find('.mCSB_container').append(htmlCodeItem);
     }
     if (suggestions.length > 0){
         $j('.' + listName).height(suggestions.length*82);
         $j('.' + listName).find('.mCSB_container .suggestions-hint').remove();
         $j('.' + listName).mCustomScrollbar('scrollTo',['top',null]);
         if (suggestions.length <= 2){
            $j('.' + listName).mCustomScrollbar('disable');
        } else {
            $j('.' + listName).mCustomScrollbar('update');
         }
    } else if(!$j('.' + listName).find('.mCSB_container').find('.suggestions-hint')[0]) {
         $j('.' + listName).height(40);
         var notFoundText = '';
         if (type == 'searchLegalAddress' || type == 'searchDocumentAddress'){
             notFoundText = 'Неизвестный адрес';
         } else if (type == 'searchBank'){
             notFoundText = 'Неизвестный банк';
             $j('.bankBic').val('');
             $j('.corBankAccount').val('');
         }
        $j('.' + listName).find('.mCSB_container').append('<div class="suggestions-hint">' + notFoundText + '</div>');
    }
}

// Generate dropdown list attributes from DaData
function generateListItem(suggestion, type, listItem){
    var htmlCodeItem = '';
    if(type == 'searchDocumentAddress' || type == 'searchLegalAddress'){
        htmlCodeItem = '<div class="' + listItem + '" data-name="' + suggestion.unrestricted_value + '" ';

        var region = '';
        if (suggestion.data.region_with_type != null) {
            region = suggestion.data.region_with_type;
        }
        htmlCodeItem += ' data-region="' + region + '" ';

        var city = '';
        if (suggestion.data.city_with_type != null) {
            city = suggestion.data.city_with_type;
        } else if (suggestion.data.settlement_with_type != null) {
            city = suggestion.data.settlement_with_type;
        }
        htmlCodeItem += ' data-city="' + city + '" ';

        var postalCode = '';
        if (suggestion.data.postal_code != null) {
            postalCode = suggestion.data.postal_code;
        }
        htmlCodeItem += ' data-postal_code="' + postalCode + '" ';

        var street = '';
        if (suggestion.data.street_with_type != null) {
            street = suggestion.data.street_with_type;
        }
        htmlCodeItem += ' data-street="' + street + '" ';

        htmlCodeItem += ' data-house="';
        if (suggestion.data.house != null) {
            htmlCodeItem += suggestion.data.house + ' ';
        }
        if (suggestion.data.block_type != null) {
            htmlCodeItem += suggestion.data.block_type + ' ';
        }
        if (suggestion.data.block != null) {
            htmlCodeItem += suggestion.data.block;
        }
        var flat = '';
        if (suggestion.data.flat != null) {
            flat = suggestion.data.flat;
        }
        htmlCodeItem += '" data-flat="' + flat;
        htmlCodeItem += '"> <strong>' + suggestion.unrestricted_value+'</strong></div>';
    } else if(type == 'searchBank'){
        var bankTown = '';
        if(suggestion.data.address.data != null) {
            bankTown = suggestion.data.address.data.city_with_type;
        }
            var bankNameShort = suggestion.data.name.short;
            if(bankNameShort == null){
                bankNameShort = suggestion.data.name.payment;
            }
            htmlCodeItem = '<div class="' + listItem + '" data-name="' + suggestion.data.name.payment.split('"').join('&amp;quote') + '" '+
                           'data-name-short="' + bankNameShort.split('"').join('&amp;quote') + '" ' +
                           'data-bic="' + suggestion.data.bic + '" '+
                           'data-kc="' + suggestion.data.correspondent_account + '" '+
                           'data-okpo="' + suggestion.data.okpo + '" '+
                           'data-town="' + bankTown + '" '+
                           'data-address="'+ suggestion.data.address.value + '" '+
                           '><strong>'+suggestion.data.name.payment+'</strong><span>'+suggestion.data.bic+'<br/>'+suggestion.data.address.value+'</span></div>';
    }
    return htmlCodeItem;
}

    // Fill dropdown list from DaData

function setDaDataInputList(inputClass,listClass){
    var inputBlock = inputClass.parent();
    if (!inputBlock.find('.'+listClass)[0]){
        inputBlock.append('<div class="' + listClass + '"></div>');
    }

     $j(document).mouseup(function (e) {
        var containers = $j('.'+listClass);
        if (containers.has(e.target).length === 0){
            containers.slideUp();
        }
    });

    $j('.' + listClass).mCustomScrollbar({
        theme: 'dark'
    });
}

function notify() {
    var notification = $j('[id$=executionStatus]').val();
    var notificationExist = notification != undefined && notification != '';

    if (notificationExist) {
        alert(notification);
        var errorBlock = $j('.errorNotificationsBlock');
        scrollToTopInput(errorBlock);
    }

    var infoMessage = $j('[id$=error]')[0].innerText;
    if (!notificationExist && infoMessage != undefined && infoMessage != '') {
        window.scrollTo(0,0);
    }
}

function downloadContractPreview(base64){
   if (base64 == undefined || base64 == '') {
       alert('Попробуйте сгенерировать отчет позже!');
       notify();
   } else {
       var companyName = $j('[id$=companyName]').val();
        saveByteArray(companyName + ' - шаблон договора.pdf', base64ToArrayBuffer(base64));
       alert('Шаблон договора успешно загружен!');
   }
}

function base64ToArrayBuffer(base64) {
    var binaryString = window.atob(base64);
    var binaryLen = binaryString.length;
    var bytes = new Uint8Array(binaryLen);
    for (var i = 0; i < binaryLen; i++) {
       var ascii = binaryString.charCodeAt(i);
       bytes[i] = ascii;
    }
    return bytes;
}

function saveByteArray(reportName, byte) {
    var blob = new Blob([byte], {type: "application/pdf"});
    var link = document.createElement('a');
    link.href = window.URL.createObjectURL(blob);
    var fileName = reportName;
    link.download = fileName;
    link.click();
}

function scrollToTopInput(block){
    var inputsFirstErrorBlock = block[0];
    if ( !isScrolledIntoView(inputsFirstErrorBlock) ){
        inputsFirstErrorBlock.scrollIntoView();
    }
}

function isScrolledIntoView(elem) {
   var docViewTop = $j(window).scrollTop();
   var docViewBottom = docViewTop + $j(window).height();

   var elemTop = $j(elem).offset().top;
   var elemBottom = elemTop + $j(elem).height();

   return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
}
