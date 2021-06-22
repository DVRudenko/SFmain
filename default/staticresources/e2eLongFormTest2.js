$j = jQuery.noConflict();

var regs = {
    phone: /^([0-9+]{13,15})+$/,
    numbers: /^[0-9]+$/,
    letters: /^[a-zA-ZÀ-ž\x7f-\xff\s'-]+$/,
    lettersAndNumbers: /^[0-9a-zA-ZÀ-ž\x7f-\xff\s'&.-]+$/,
    embossingLetters: /^[a-zA-Z\s]+$/, // letters for embossing on card (important for GFN)
    embossingLettersAndNumbers: /^[0-9a-zA-Z\s]+$/, // letters and numbers for embossing on card (important for GFN)
    email: /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/,
    carNumberFormat_DE: /^[0-9A-Za-z]{1,3}\-?\s?[A-Za-z]{0,3}\-?\s?[0-9]{1,4}[H]{0,1}/,
    swiftFormat: /^([a-zA-Z]){4}([a-zA-Z]){2}([0-9a-zA-Z]){2}([0-9a-zA-Z]{3})?$/,
    ibanFormat_DE: /^[DEde]{2}[0-9]{2}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\s?[0-9]{2}?$/
};
var chatActivityTimeout;
var chatOfflineUpdateTimeout;
var chatOfflineOLDText;
var minPumpValue = 75;
var maxPumpValue = 50000;

var dataSource = 'eurolocator.fleetcor.de';
var favStationInfo = '';
var errors = {
 0 :'ZERO_SEARCH_RESULTS'
}

$j(function() {
    onPageLoad();
    onPageRender();
});

$j(document).ready(function () {
    var content = $j('.step-content');

    /* STEP CONTACT DETAILS */
    var contactDetailsStepBlock = content.find('.contact-details');
    contactDetailsStepBlock.find('.btn-red').attr('disabled', true);

    var firstNameInput = contactDetailsStepBlock.find('.first-name').find('input');
    if(firstNameInput.val() != '' && firstNameInput.val() != undefined) {
        isInputValueValid(firstNameInput, new RegExp(regs.letters));
    }

    var lastNameInput = contactDetailsStepBlock.find('.last-name').find('input');
    if(lastNameInput.val() != '' && lastNameInput.val() != undefined) {
        isInputValueValid(lastNameInput, new RegExp(regs.letters));
    }

    var phoneInput = contactDetailsStepBlock.find('.phone').find('input');
    phoneInput.inputmask({mask:"+4\\9999999999999", "placeholder": "" }); //using jqueryInputMask.resource
    if(phoneInput.val() != '' && phoneInput.val() != undefined){
        isInputValueValid(phoneInput, new RegExp(regs.phone));
    }

    var emailInput = contactDetailsStepBlock.find('.email').find('input');
    if(emailInput.val() != '' && emailInput.val() != undefined){
        isInputValueValid(emailInput, new RegExp(regs.email));
    }

    var contactDetails_requiredInputs = contactDetailsStepBlock.find('.form-control.required');
    checkRequiredFields(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));

    setEvents_contactDetails();

    /* STEP COMPANY DETAILS */
    var creditScoringStepBlock = content.find('.credit-scoring');
    creditScoringStepBlock.find('.btn-red').attr('disabled', true);
    creditScoringStepBlock.find('.btn-red.search').attr('disabled', true);

    var companyInput = creditScoringStepBlock.find('.company').find('input');
    if(companyInput.val() != '' && companyInput.val() != undefined){
        isInputValueValid(companyInput, new RegExp(regs.lettersAndNumbers));
    }

    var taxIdInput = creditScoringStepBlock.find('.tax-id').find('input');
    if(taxIdInput.val() != '' && taxIdInput.val() != undefined){
        validateTaxId(taxIdInput, new RegExp(regs.numbers));
    }

    var creditScoring_requiredInputs = creditScoringStepBlock.find('.form-control.required');
    checkRequiredFields(creditScoring_requiredInputs, creditScoringStepBlock.find('.btn-red.search'));
    var cfCompanies = creditScoringStepBlock.find('input[type = "radio"]');
    if(isRadioButtonSelected(cfCompanies)){
        checkRequiredFields(creditScoring_requiredInputs, creditScoringStepBlock.find('.btn-red.continue'));
    }

    setEvents_companyDetails();

    /* STEP FUEL CONSUMPTION */
    var fuelConsumptionStepBlock = content.find('.fuel-consumption');
    fuelConsumptionStepBlock.find('.btn-red').attr('disabled', true);

    var pumpInput = fuelConsumptionStepBlock.find('.pump').find('input');
    if(pumpInput.val() != '' && pumpInput.val() != undefined) {
        validatePumpInputValue(pumpInput, new RegExp(regs.numbers));
    }

    setEvents_fuelConsumption();

    /* STEP CREDIT LINE */
    var creditLineStepBlock = content.find('.credit-line');
    var creditLine_requiredInputs = creditLineStepBlock.find('.form-control.required');
    var creditLimit = creditLineStepBlock.find('.credit-limit').find($j('[id$="creditLimit"]'));
    validateCreditLimitValue(creditLimit);

    setEvents_creditLimit();

    /* STEP CARDS ORDER */
    var cardsOrderStepBlock = content.find('.cards-order');

    showCardsOrderNavigationTabs();

    // Event for same cards switches
    var isPumpOutsideOn = $j('#outsideSwitch input').is(':checked');
    showInternationalTransactionInfo(isPumpOutsideOn);

    var isPumpAtPartners = $j('#partnerSwitch input').is(':checked');
    showFuelPartnerTransactionInfo(isPumpAtPartners);

    // Event for different cards switches (show information clock in blue wrapper if one of switches is checked)
    var differentCardsTab = $j('.cards-categories .tab-content').find('#diffCards');
    var cardsOutsideSwitchers = differentCardsTab.find('.onoffswitch.outside input');
    showInternationalTransactionInfo(isSwitchChecked(cardsOutsideSwitchers));
    var cardsPartnerSwitchers = differentCardsTab.find('.onoffswitch.partner input');
    showFuelPartnerTransactionInfo(isSwitchChecked(cardsPartnerSwitchers));

    setEvents_cardsOrder();

    /* STEP SPECIAL OFFERS */
    var specialOfferBlock = $j('.special-offers .offer');
    specialOfferBlock.find('.btn-red.my-station').attr('disabled', true);

    setEvents_specialOffers();

    window.addEventListener('message', function(event) {
        if (~event.origin.indexOf(dataSource)) {
            var noDataMessage = $j('.locator-error-message1');
            var wrongAddressMessage = $j('.locator-error-message2');
            wrongAddressMessage.hide();
            noDataMessage.hide();
            if(event.data.id) {
                favStationInfo = (event.data.townName).toLowerCase() + ', ' + (event.data.address).toLowerCase();
                $j('<span>' + favStationInfo + '</span>').insertBefore('.special-offers .offer .fav-station .edit');
                return;
            }

            if(event.data.error === errors[0]) {
                wrongAddressMessage.show();
                return;
            }

            if(event.data.numberOfPoints == 0){
                noDataMessage.show();
                return;
            }
        } else {
            // if a source of data is not a site-locator then do nothing
            return;
        }
    });

    /* STEP CARDS TECHNICAL PARAMETERS */
    var cardTechParamsBlock = content.find('.cards-tech-parameters');
    cardTechParamsBlock.find('.btn-red.save-params').attr('disabled', true);

    var cardTechParamsItems =  cardTechParamsBlock.find('.cards-list .card-item');
    var selectedCardOwnerType = cardTechParamsItems.find('.card-owner-type input.selected').val();
    if(!(selectedCardOwnerType == undefined)){
        if(selectedCardOwnerType.toLowerCase() === 'driver name'){
            switchingToDriverName();
        } else {
            switchingToCarNumber();
        }
    }

    cardTechParamsItems.each(function(){
        var selectedCardOwnerType = cardTechParamsItems.closest('.card-item').find('.card-owner-type').find('[id$="selectDriverNameOrCarNumber"]').attr('class');
        var cardOwnerInput = cardTechParamsItems.find('.card-param-value input');
        if(cardOwnerInput.val() != '' && cardOwnerInput.val() != undefined){
            if(!(selectedCardOwnerType == undefined)){
                if(selectedCardOwnerType.toLowerCase() === 'car-number'){
                    isInputValueValid(cardOwnerInput, new RegExp(regs.carNumberFormat_DE));
                }
                if(selectedCardOwnerType.toLowerCase() === 'driver-name'){
                    isInputValueValid(cardOwnerInput, new RegExp(regs.embossingLetters));
                }
            }
        }

        var companyInput = cardTechParamsItems.find('.company-name input');
        if(companyInput.val() != '' && companyInput.val() != undefined){
            isInputValueValid(companyInput, new RegExp(regs.embossingLettersAndNumbers));
        }
    });

    //set company name counter
    counterLenCompanyName();

    setEvents_cardsTechnicalParams();

    /* STEP PAYMENT - DIRECT DEBIT */
    var paymentDirectDebitBlock = content.find('.payment-direct-debit');
    paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);

    var accountHolderInput = paymentDirectDebitBlock.find('.account-holder').find('input');
    if(accountHolderInput.val() != '' && accountHolderInput.val() != undefined) {
        isInputValueValid(accountHolderInput, new RegExp(regs.letters));
    }

    var ibanInput = paymentDirectDebitBlock.find('.iban').find('input');
    if(ibanInput.val() != '' && ibanInput.val() != undefined) {
        isInputValueValid(ibanInput, new RegExp(regs.ibanFormat_DE));
    }

    var swiftInput = paymentDirectDebitBlock.find('.swift').find('input');
    if(swiftInput.val() != '' && swiftInput.val() != undefined) {
        isInputValueValid(swiftInput, new RegExp(regs.swiftFormat));
    }

    var paymentDirectDebit_requiredInputs = paymentDirectDebitBlock.find('.form-control.required');
    checkRequiredFields(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));

    setEvents_directDebit();

    /* STEP PAYMENT - BANK TRANSFER DEPOSIT */
    var paymentBankTransferBlock = content.find('.payment-bank-transfer');
    paymentBankTransferBlock.find('.btn-red.continue').attr('disabled', true);

    setEvents_bankTransferDebit();

    /* STEP PAYMENT - DIRECT DEBIT DEPOSIT */
    var directDebitBlock = content.find('.direct-debit-deposit');
    directDebitBlock.find('.btn-red').attr('disabled', true);

    var paymentMethods = directDebitBlock.find('.category-link');
    validDirectDebitForm(directDebitBlock, paymentMethods);

    setEvents_directDebitDeposit();

    /* STEP PAYMENT - BANK TRANSFER NO DEPOSIT */
    var bankTransferNoDepositBlock = content.find('.bank-transfer-no-deposit');
    bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', true);

    setEvents_bankTransferNoDeposit();
    setChatOptions();
});

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

function checkRequiredFields(inputs, button){
    var empty = false;
    var hasErrors = false;
    inputs.each(function() {
        if($j(this).val() == '') {
            empty = true;
        }
        if($j(this).hasClass('error')){
            hasErrors = true;
        }
    });

    if (empty || hasErrors) {
        button.attr('disabled', true);
    } else {
        button.attr('disabled', false);
    }
}

function isRadioButtonSelected(radioInputs){
    var selected = false;
    radioInputs.each(function() {
        if($j(this).is(':checked')){
            selected = true;
        }
    });
    return selected;
}

function isSwitchChecked(switches){
    var isChecked = false;
    switches.each(function() {
        if($j(this).is(':checked')){
            isChecked = true;
        }
    });
    return isChecked;
}

function validateContactDetails(moveToNextStep){
    var currentStepBlock = $j('.step-content .contact-details');
    var firstNameInput = currentStepBlock.find('.first-name').find('input');
    var lastNameInput = currentStepBlock.find('.last-name').find('input');
    var phoneInput = currentStepBlock.find('.phone').find('input');
    var emailInput = currentStepBlock.find('.email').find('input');

    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(firstNameInput, new RegExp(regs.letters)));
    validatedFields.push(isInputValueValid(lastNameInput, new RegExp(regs.letters)));
    validatedFields.push(isInputValueValid(phoneInput, new RegExp(regs.phone)));
    validatedFields.push(isInputValueValid(emailInput, new RegExp(regs.email)));
    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    var isAgreementChecked = currentStepBlock.find('input[type="checkbox"]').is(':checked');
    var isNextStepDisabled = currentStepBlock.find('.btn-red').is('[disabled=disabled]');
    if(isValid && !isNextStepDisabled && isAgreementChecked){
       if (moveToNextStep) {
            goToCreditScoring();
       }
       return true;
    } else {
       return false;
    }
}

function validateTaxId(element, regex) {
    var isValid = false;
    var taxIdSize = element.val().length;
    var elementValue = element.val();
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if(taxIdSize >= 9 && taxIdSize <= 12){
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
    } else {
        element.closest('.form-group input').removeClass('success');
        element.closest('.form-group input').addClass('error');
        element.closest('.form-group').find('.invalid-feedback').show();
        element.closest('.form-group').find('.glyphicon').hide();
        isValid = false;
    }
    return isValid;
}

function validateCompanyDetails(moveToNextStep){
    var currentStepBlock = $j('.step-content .credit-scoring');
    var companyNameInput = currentStepBlock.find('.company').find('input');
    var taxIdInput = currentStepBlock.find('.tax-id').find('input');
    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(companyNameInput, new RegExp(regs.lettersAndNumbers)));
    validatedFields.push(validateTaxId(taxIdInput, new RegExp(regs.numbers)));
    isValid = validatedFields.indexOf(false) != -1 ? false : true;
    var isNextStepDisabled = currentStepBlock.find('.btn-red').is('[disabled=disabled]');
    if(isValid && !isNextStepDisabled){
        if(moveToNextStep){
            goToFuelConsumption();
        }
       return true;
    } else {
       return false;
    }
}

function recheckCompanyDetails() {
    var creditScoringStepBlock = $j('.step-content .credit-scoring');
    var creditScoring_requiredInputs = creditScoringStepBlock.find('.form-control.required');
    checkRequiredFields(creditScoring_requiredInputs, creditScoringStepBlock.find('.btn-red.search'));
}

function validateCompanyDetailsForSearch(){
    var currentStepBlock = $j('.step-content .credit-scoring');
    var companyNameInput = currentStepBlock.find('.company').find('input');
    var taxIdInput = currentStepBlock.find('.tax-id').find('input');
    var isValid = false;
    var validatedFields = [];
    validatedFields.push(isInputValueValid(companyNameInput, new RegExp(regs.lettersAndNumbers)));
    validatedFields.push(validateTaxId(taxIdInput, new RegExp(regs.numbers)));
    isValid = validatedFields.indexOf(false) != -1 ? false : true;
    var isNextStepDisabled = currentStepBlock.find('.btn-red.search').is('[disabled=disabled]');
    if(isValid && !isNextStepDisabled){
       doSearchCompany();
       return true;
    } else {
       return false;
    }
}

function validatePumpInputValue(inputElement, regex) {
    var pumpValue = inputElement.val();
    var elementValue = inputElement.val();
    if((elementValue.trim() != '') && regex.test(elementValue)){
        if(pumpValue < minPumpValue || pumpValue > maxPumpValue) {
            inputElement.closest('.form-group input').addClass('error');
            inputElement.closest('.wrapper').find('.i-error').show();
            inputElement.closest('.wrapper').find('.limit-info').css("color", '#EE3A43');
            inputElement.closest('.wrapper').find('.btn-red').attr('disabled', true);
        } else {
            inputElement.closest('.form-group input').removeClass('error');
            inputElement.closest('.wrapper').find('.i-error').hide();
            inputElement.closest('.wrapper').find('.limit-info').css("color", '#1A1A1A');
            inputElement.closest('.wrapper').find('.btn-red').attr('disabled', false);
        }
    } else {
        inputElement.closest('.form-group input').addClass('error');
        inputElement.closest('.wrapper').find('.i-error').show();
        inputElement.closest('.wrapper').find('.limit-info').css("color", '#EE3A43');
        inputElement.closest('.wrapper').find('.btn-red').attr('disabled', true);
    }
}

function validatePumpDetails() {
    var currentStepBlock = $j('.step-content .fuel-consumption');
    var isNextStepDisabled = currentStepBlock.find('.btn-red').is('[disabled=disabled]');
    var isValid = false;
    if(!isNextStepDisabled){
        goToOfferCreditLine();
        isValid = true;
    }

    var pumpValue = currentStepBlock.find('.pump').find('input').val();
    if(pumpValue < minPumpValue || pumpValue > maxPumpValue){
        isValid = false;
    }
    return isValid;
}

function validateCreditLimit(moveToNextStep){
    var currentStepBlock = $j('.step-content .credit-line');
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var isValid = false;
    if(!isNextStepDisabled){
        if(moveToNextStep){
            analytics_goToCardsConfig();
            goToCardsOrder();
        }
        isValid = true;
    }
    return isValid;
}

function validateCreditLimitValue(inputElement) {
    var limitValue = (inputElement.html() === '' ? 0 : parseInt(inputElement.html()));
    var minCreditValue = parseInt($j('.slider-label-first').html());
    var maxCreditValue = parseInt($j('.slider-label-last').html());
    if(limitValue < minCreditValue || limitValue > maxCreditValue) {
        inputElement.closest('.form-group input').addClass('error');
        inputElement.closest('.form-group').find('.invalid-feedback').show();
        inputElement.closest('.wrapper').find('.btn-red').attr('disabled', true);
    } else {
        inputElement.closest('.form-group input').removeClass('error');
        inputElement.closest('.form-group').find('.invalid-feedback').hide();
        inputElement.closest('.wrapper').find('.btn-red').attr('disabled', false);
    }
}

function checkCardsCounter(){
    var currentStepBlock = $j('.step-content .cards-order');
    var isValid = false;
    var counter = parseInt($j('.cards-count input').val());
    var numberOfCards = $j('.diff-cards-category .cards-list').find('.card-item').size();

    if(numberOfCards > 1 && counter == 1) {
        $j('.b-nav-cards').find('.tab1').removeClass('active');
        $j('.b-nav-cards').find('.tab2').addClass('active');
    }
}

function checkCardOwner(){
    var content = $j('.step-content');
    var cardTechParamsBlock = content.find('.cards-tech-parameters');
    var cardTechParamsItems = cardTechParamsBlock.find('.cards-list .card-item');

    var selectedCardOwnerType = cardTechParamsItems.closest('.card-item').find('.card-owner-type').find('[id$="selectDriverNameOrCarNumber"]').attr('class');
    var cardOwnerInput = cardTechParamsBlock.find('.cards-list .card-item .card-param-value input');
    if(cardOwnerInput.val() != '' && cardOwnerInput.val() != undefined){
        if(!(selectedCardOwnerType == undefined)){
            if(cardOwnerInput.val() != ''){
                if(selectedCardOwnerType.toLowerCase() === 'car-number'){
                    isInputValueValid(cardOwnerInput, new RegExp(regs.carNumberFormat_DE));
                }
                if(selectedCardOwnerType.toLowerCase() === 'driver-name'){
                    isInputValueValid(cardOwnerInput, new RegExp(regs.embossingLetters));
                }
            }

        }
    }
}

function checkCardTechParams() {
    var content = $j('.step-content');
    var cardTechParamsBlock = content.find('.cards-tech-parameters');
    var cardTechParamsItems = cardTechParamsBlock.find('.cards-list .card-item');

    var continueButton = cardTechParamsBlock.find('.btn-red.continue');

    var isCardOwnerValid = false;
    var isCompanyValid = false;

    var selectedCardOwnerType = cardTechParamsItems.closest('.card-item').find('.card-owner-type').find('[id$="selectDriverNameOrCarNumber"]').attr('class');
    var cardOwnerInput = cardTechParamsBlock.find('.cards-list .card-item .card-param-value input');
    if(cardOwnerInput.val() != '' && cardOwnerInput.val() != undefined){
        if(!(selectedCardOwnerType == undefined)){
            if(selectedCardOwnerType.toLowerCase() === 'car-number'){
                isCardOwnerValid = isInputValueValid(cardOwnerInput, new RegExp(regs.carNumberFormat_DE));
            }
            if(selectedCardOwnerType.toLowerCase() === 'driver-name'){
                isCardOwnerValid = isInputValueValid(cardOwnerInput, new RegExp(regs.embossingLetters));
            }
        }
    }

    var companyInput = cardTechParamsItems.find('.company-name input');
    if(companyInput.val() != undefined){
        isCompanyValid = isInputValueValid(companyInput, new RegExp(regs.embossingLettersAndNumbers));
    }

    if(!isCardOwnerValid && !isCardOwnerValid){
        continueButton.find('disabled', true);
    }
}

function validateCardsTechParams(index) {
    var currentStepBlock = $j('.step-content .cards-tech-parameters');
    var isNextStepDisabled = currentStepBlock.find('.btn-red.btn-done').is('[disabled=disabled]');
    var isValid = false;
    var validatedFields = [];
    var cardTechParamsItems = currentStepBlock.find('.cards-list .card-item');

    var selectedCardOwnerType = cardTechParamsItems.closest('.card-item').find('.card-owner-type').find('[id$="selectDriverNameOrCarNumber"]').attr('class');
    var cardOwnerInput = currentStepBlock.find('.cards-list .card-item .card-param-value input');
    if(cardOwnerInput.val() != undefined){
        if(selectedCardOwnerType != undefined){
            if(selectedCardOwnerType.toLowerCase() === 'car-number'){
                validatedFields.push(isInputValueValid(cardOwnerInput, new RegExp(regs.carNumberFormat_DE)));
            }
            if(selectedCardOwnerType.toLowerCase() === 'driver-name'){
                validatedFields.push(isInputValueValid(cardOwnerInput, new RegExp(regs.embossingLetters)));
            }
        }
    }

    var companyInput = cardTechParamsItems.find('.company-name input');
    if(companyInput.val() != undefined){
        validatedFields.push(isInputValueValid(companyInput, new RegExp(regs.embossingLettersAndNumbers)));
    }

    isValid = validatedFields.indexOf(false) != -1 ? false : true;

    if(!isNextStepDisabled && isValid){
        saveTechParamForSingleCard(index);
    }
    return false;
}

function validatePaymentDirectDebit(){
     var currentStepBlock = $j('.step-content .payment-direct-debit');
     var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
     var isValid = false;
     if(!isNextStepDisabled){
         goToCongratulations();
         isValid = true;
     }
     return isValid;
}

function validateBankTransferNoDeposit(){
    var currentStepBlock = $j('.step-content .bank-transfer-no-deposit');
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var isValid = false;
    if(!isNextStepDisabled){
        goToCongratulations();
        isValid = true;
    }
    return isValid;
}

function validDirectDebitForm(block, paymentMethods){
    var methods = [];
    paymentMethods.each(function(){
        if($j(this).hasClass('active')){
            methods.push(true);
        } else {
            methods.push(false);
        }
    });

    var isAgreementChecked = block.find('input[type="checkbox"]').is(':checked');
    if(methods.indexOf(true) != -1 && isAgreementChecked){
        block.find('.btn-red').attr('disabled', false);
    } else {
        block.find('.btn-red').attr('disabled', true);
    }
}

function validBankTransferForm(block, paymentMethods, confirmedAgreements){
    var tempMethods = [];
    paymentMethods.each(function(){
        if($j(this).hasClass('active')){
            tempMethods.push(true);
        } else {
            tempMethods.push(false);
        }
    });

    if(tempMethods.indexOf(true) != -1){
        if(confirmedAgreements.indexOf(false) != -1){
            block.find('.btn-red.continue').attr('disabled', true);
        } else {
            block.find('.btn-red.continue').attr('disabled', false);
        }
    }
}

/*   ----------------------------
 *    Method to create the Slider
 *    ----------------------------
 *    PARAMETERS : "destination" = The Id of the div where the slider needs to be created
 *                 "dispOutput" = The Id of the div where the slider value needs to be displayed
 *                 "idInputHidden" = The Id of the apex inputHidden component
 *                 "startVal" = initial position of slider
 *                 "minVal", "maxVal" = minimum and maximum value of slider
 **/
function createSlider(destination, dispOutput, idInputHidden, startVal, minVal, maxVal){
    $j('#' + destination).slider({
        range: false,
        min: minVal,
        max: maxVal,
        values: [startVal],
        step: 100,
        slide: function(event, ui){
        //This function executes every time slider is moved and applies the slider values
        //to the input fields as well as the output below the slider
            $j('[id$=' + idInputHidden + ']').val(ui.values[0]);
            $j('[id$=' + dispOutput + ']').text(ui.values[0]);
            colorSliderActiveLine();
        },
        stop: function(event, ui){
            recalculateDeposit();
            colorSliderActiveLine();
        }
    });
    //write the initial value in the display div
    $j('[id$=" + dispOutput + "]').text(startVal);
}

function colorSliderActiveLine() {
    var sliderHandler = $j('#slider').find('.ui-slider-handle')[0];
    var sliderLeftWidth;
    if(sliderHandler != undefined){
        sliderLeftWidth = parseInt($j('#slider').find('.ui-slider-handle')[0].style.left.split('%')[0]);
        $j('#slider').find('.slider-active-line')[0].style.width = sliderLeftWidth + '%';
    }
}

function increaseCards() {
    var counter = parseInt($j('.cards-count .number-wrapper input').val());
    if(counter < 50){
        $j('.cards-count .number-wrapper input').val(counter + 1);
        // if(parseInt($j('.cards-count .number-wrapper input').val()) > 1){
        //     $j('.b-nav-cards').find('.nav').show();
        // }
    }
}

function reductionCards() {
    var counter = parseInt($j('.cards-count .number-wrapper input').val());
    if(counter > 1){
        $j('.cards-count .number-wrapper input').val(counter - 1);
        // if(parseInt($j('.cards-count .number-wrapper input').val()) <= 1){
        //     $j('.b-nav-cards').find('.nav').hide();
        // }
    }

    // var newCounter = parseInt($j('.cards-count .number-wrapper input').val());
    // var numberOfCards = $j('.diff-cards-category .cards-list').find('.card-item').size();
    // if(newCounter <= 1 && numberOfCards == 1){
    //     $j('.b-nav-cards').find('.tab1 a').click();
    //     showCardsOrderNavigationTabs();
    // }
}

function showCardsOrderNavigationTabs(){
    // var cardsCounter = parseInt($j('.cards-count .number-wrapper input').val());
    // var navTabs = $j('.b-nav-cards').find('.nav');
    // cardsCounter <= 1 ? navTabs.hide() : navTabs.show();
}

function showInternationalTransactionInfo(isPumpOutsideOn) {
    if(!isPumpOutsideOn){
        $j('.wrapper.blue-block').find('#internationalTrans').hide();
    } else {
        $j('.wrapper.blue-block').find('#internationalTrans').show();
    }
}

function showFuelPartnerTransactionInfo(isPumpAtPartners) {
    if(!isPumpAtPartners){
        $j('.wrapper.blue-block').find('#partnerTrans').hide();
    } else {
        $j('.wrapper.blue-block').find('#partnerTrans').show();
    }
}

function showLocator(){
    $j('.b-locator').show();
    var specialOfferBlock = $j('[id$="chooseStation"]');
    var isButtonDisabled = specialOfferBlock.find('.btn-red').hasClass('is-disabled');
    if(!isButtonDisabled){
        specialOfferBlock.find('.choose-station-btn').hide();
        specialOfferBlock.find('.save-station-btn').show();
    }
    return false;
}

function pickStation(){
    var specialOfferBlock = $j('[id$="chooseStation"]');
    var isButtonDisabled = specialOfferBlock.find('.btn-red.my-station').is('[disabled=disabled]');
    if(!isButtonDisabled){
        $j('.b-locator').hide();
        specialOfferBlock.find('.offer-label .arrow-right').addClass('selected');
        specialOfferBlock.find('.offer-label .price-right').addClass('selected');
        specialOfferBlock.find('.save-station-btn').hide();
        specialOfferBlock.find('.fav-station').show();
        //saveStation();
    }
    return false;
}

function cancelStationChoice(){
    var specialOfferBlock = $j('[id$="chooseStation"]');
    specialOfferBlock.find('.offer-label .arrow-right').removeClass('selected');
    specialOfferBlock.find('.offer-label .price-right').removeClass('selected');
    specialOfferBlock.find('.fav-station').hide();
    specialOfferBlock.find('.choose-station-btn').show();
    //removeStation();
    return false;
}

function setShellDiscount(){
    var specialOfferBlock = $j('[id$="allShellDiscount"]');
    var isButtonDisabled = specialOfferBlock.find('.btn-red').hasClass('is-disabled');
    if(!isButtonDisabled){
        specialOfferBlock.find('.offer-label .arrow-right').addClass('selected');
        specialOfferBlock.find('.offer-label .price-right').addClass('selected');
        specialOfferBlock.find('.save-btn').hide();
        specialOfferBlock.find('.remove-btn').show();
        //setAllShellDiscounts();
    }
    return false;
}

function cancelShellDiscount(){
    var specialOfferBlock = $j('[id$="allShellDiscount"]');
    specialOfferBlock.find('.offer-label .arrow-right').removeClass('selected');
    specialOfferBlock.find('.offer-label .price-right').removeClass('selected');
    specialOfferBlock.find('.save-btn').show();
    specialOfferBlock.find('.remove-btn').hide();
    //removeShellDiscount();
    return false;
}

function enableDisableContinueButton() {
    var disabledButtons = $j('.cards-tech-parameters .cards-list .btn-done:disabled');
    if (disabledButtons.length == 0) {
        $j('.cards-tech-parameters .btn.continue').removeAttr('disabled');
    } else {
        $j('.cards-tech-parameters .btn.continue').attr('disabled', true);
    }
}

function switchingToDriverName() {
    var cardTechParamsItems =  $j('.cards-tech-parameters .cards-list .card-item');
    cardTechParamsItems.find('.card-param.driver').show();
    cardTechParamsItems.find('.card-param.car').hide();
}

function switchingToCarNumber() {
    var cardTechParamsItems =  $j('.cards-tech-parameters .cards-list .card-item');
    cardTechParamsItems.find('.card-param.driver').hide();
    cardTechParamsItems.find('.card-param.car').show();
}

function counterLenCompanyName() {
    var cardTechParamsItems =  $j('.cards-tech-parameters .cards-list .card-item');
    var companyName = cardTechParamsItems.find('.company-name input')[0];
    if(!(companyName == undefined)){
        cardTechParamsItems.find('.company-name .len-company-name').text(companyName.value.length + '/' + companyName.maxLength);
    }

    cardTechParamsItems.find('.company-name').on('keyup', function() {
        cardTechParamsItems.find('.company-name .len-company-name').text(companyName.value.length + '/' + companyName.maxLength);
    });
}

function  startPayment(block){
    var currentStepBlock = $j('.step-content .' + block);
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var isValid = false;
    var form = document.getElementById("paymentFormToSubmit");
    if(!isNextStepDisabled){
        form.submit();
        isValid = true;
    }
    return isValid;
}

function updatePaymentMethod(input, textId) {
    var radioBtn = document.getElementById(textId);
    if (radioBtn != null){
       radioBtn.value = input.value;
       changeMethod();
    }
}

function printDocument(frameName) {
    window.frames[frameName].print();
}

function printPaymentInformation(){
    var divToPrint = document.getElementById('paymentInformation');
    var htmlTemplate = '<html><body onload="window.print()">' + divToPrint.innerHTML + '</body></html>'
    var newWin = window.open('','Payment Information');
    newWin.document.open();
    newWin.document.write(htmlTemplate);
    newWin.document.close();
    setTimeout(function(){
        newWin.close();
    }, 10);
}

/* IMPORTANT!!! This is for event functions on blocks (should recall on complete methods when blocks are rerendering) */
function onPageLoad(){
    /* GENERAL EVENTS */
    // create range slider
    createSlider('slider', 'creditLimitInput', 'idInputHidden', 100, 100, 600);
    if($j('#slider').find('.slider-active-line').length == 0) {
        $j('#slider').append('<div class="slider-active-line" style="width:0%"></div>');
    }

    // Switchers event
    var switchBlocks = $j('.b-switch-block');
    switchBlocks.each(function(){
        var switcher = $j(this).find('.onoffswitch .onoffswitch-checkbox');
        if(!switcher.is(':checked')){
            $j(this).css('background', '#f6f6f6');
        }
    });

    $j('.onoffswitch .onoffswitch-checkbox').on('click', function(){
        var switchBlock = $j(this).parents().closest('.b-switch-block');
        if($j(this).is(':checked')){
            switchBlock.css('background', '#cecece');
            switchBlock.find('.onoffswitch-switch').css({ 'margin': '8px', 'background': '#ffffff' });
        } else {
            switchBlock.css('background', '#f6f6f6');
            switchBlock.find('.onoffswitch-switch').css({ 'margin': '8px', 'background': '#cecece' });
        }
    });


    setCollapseBlockEvent();
}

function onPageRender() {
    $j('[data-toggle="popover"]').popover();
}

function setCollapseBlockEvent(){
    // Collapse details block event
    $j('.collapse-block .link').on('click', function(){
        var detailsBlock = $j(this).parent().find('.row');
        var collapseBlock = $j(this).find('.expander');
        if(detailsBlock.is(':hidden')){
            collapseBlock.removeClass('expend-detail').addClass('collapse-detail');
            $j(this).find('.more').hide();
            $j(this).find('.less').show();
        } else {
            collapseBlock.removeClass('collapse-detail').addClass('expend-detail');
            $j(this).find('.less').hide();
            $j(this).find('.more').show();
        }
    });
}

function setEvents_contactDetails() {
    var content = $j('.step-content');
    var contactDetailsStepBlock = content.find('.contact-details');

    var firstNameInput = contactDetailsStepBlock.find('.first-name').find('input');
    firstNameInput.on('input', function(e){
        isInputValueValid(firstNameInput, new RegExp(regs.letters));
    });

    var lastNameInput = contactDetailsStepBlock.find('.last-name').find('input');
    lastNameInput.on('input', function(e){
        isInputValueValid(lastNameInput, new RegExp(regs.letters));
    });

    var phoneInput = contactDetailsStepBlock.find('.phone').find('input');
    phoneInput.inputmask({mask:"+4\\9999999999999", "placeholder": "" }); //using jqueryInputMask.resource
    phoneInput.on('input', function(e){
        isInputValueValid(phoneInput, new RegExp(regs.phone));
    });

    var emailInput = contactDetailsStepBlock.find('.email').find('input');
    emailInput.on('input', function (e){
        isInputValueValid(emailInput, new RegExp(regs.email));
    });

    var agreement = contactDetailsStepBlock.find('input[type="checkbox"]');
    var contactDetails_requiredInputs = contactDetailsStepBlock.find('.form-control.required');
    contactDetails_requiredInputs.keyup(function() {
        checkRequiredFields(contactDetails_requiredInputs, contactDetailsStepBlock.find('.btn-red'));
        if(!agreement.is(':checked')){
            contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
        }
    });

    var isAgreementChecked = agreement.is(':checked');
    if(!isAgreementChecked){
        contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
    }
    agreement.on('click', function(){
        var requiredFieldsValid = false;
        contactDetails_requiredInputs.each(function(){
            if($j(this).val() != ''){
                if($j(this).hasClass('error')){
                    requiredFieldsValid = false;
                    return false;
                } else {
                    requiredFieldsValid = true;
                }
            } else {
                requiredFieldsValid = false;
                return false;
            }
        });

        if(requiredFieldsValid && agreement.is(':checked')){
            contactDetailsStepBlock.find('.btn-red').attr('disabled', false);
        } else {
            contactDetailsStepBlock.find('.btn-red').attr('disabled', true);
        }
    });
    setCollapseBlockEvent();
}

function setEvents_companyDetails() {
    var content = $j('.step-content');
    var creditScoringStepBlock = content.find('.credit-scoring');

    var companyInput = creditScoringStepBlock.find('.company').find('input');
    if(companyInput.val() != '' && companyInput.val() != undefined){
        isInputValueValid(companyInput, new RegExp(regs.lettersAndNumbers));
    }
    companyInput.on('input', function(e){
        isInputValueValid(companyInput, new RegExp(regs.lettersAndNumbers));
    });

    var taxIdInput = creditScoringStepBlock.find('.tax-id').find('input');
    if(taxIdInput.val() != '' && taxIdInput.val() != undefined){
        validateTaxId(taxIdInput, new RegExp(regs.numbers));
    }
    taxIdInput.on('input', function(e){
        validateTaxId(taxIdInput, new RegExp(regs.numbers));
    });

    var creditScoring_requiredInputs = creditScoringStepBlock.find('.form-control.required');
    var cfCompanies = creditScoringStepBlock.find('input[type = "radio"]');
    creditScoring_requiredInputs.keyup(function() {
        checkRequiredFields(creditScoring_requiredInputs, creditScoringStepBlock.find('.btn-red.search'));
    });

    var chatButtonOnline = document.getElementById("chat-button-online");
    if(chatButtonOnline != null){
        chatButtonOnline.style.visibility = "visible";
    }

    var chatButtonOffline = document.getElementById("chat-button-offline");
    if(chatButtonOffline != null){
        chatButtonOffline.style.visibility = "visible";
    }
    setCollapseBlockEvent();
}

function setEvents_fuelConsumption() {
    var content = $j('.step-content');
    var fuelConsumptionStepBlock = content.find('.fuel-consumption');
    var pumpInput = fuelConsumptionStepBlock.find('.pump').find('input');

    pumpInput.on('input', function(e){
        validatePumpInputValue(pumpInput, new RegExp(regs.numbers));
    });

    pumpInput.change(function(){
        validatePumpInputValue(pumpInput, new RegExp(regs.numbers));
    });

    pumpInput.on('mouseout', function(){
        validatePumpInputValue(pumpInput, new RegExp(regs.numbers));
    });
    setCollapseBlockEvent();
}

function setEvents_creditLimit() {
    var content = $j('.step-content');
    var creditLineStepBlock = content.find('.credit-line');
    var creditLimit = creditLineStepBlock.find('.credit-limit').find($j('[id$="creditLimitInput"]'));
    validateCreditLimitValue(creditLimit);

    var minLimit = parseInt(creditLineStepBlock.find('.min-limit').html());
    var maxLimit = parseInt(creditLineStepBlock.find('.max-limit').html());
    createSlider('slider', 'creditLimitInput', 'idInputHidden', creditLimit.text(), minLimit, maxLimit);
    if($j('#slider').find('.slider-active-line').length == 0) {
        $j('#slider').append('<div class="slider-active-line" style="width:0%"></div>');
    }
    colorSliderActiveLine();

    creditLimit.unbind('DOMSubtreeModified');
    creditLimit.bind('DOMSubtreeModified', function(){
        colorSliderActiveLine();
    });

    var slider = $j('#slider');
    slider.on('click mousemove mouseout mouseleave', function(){
        colorSliderActiveLine();
    });

    setCollapseBlockEvent();
}

function setEvents_cardsOrder(){
    var content = $j('.step-content');
    var cardsOrderStepBlock = content.find('.cards-order');

    showCardsOrderNavigationTabs();

    // Event for same cards switches
    $j('#outsideSwitch input').change(function(){
        var canPumpOutside = $j('#outsideSwitch input').is(':checked');
        showInternationalTransactionInfo(canPumpOutside);
    });

    $j('#partnerSwitch input').change(function(){
        var canPumpAtPartners = $j('#partnerSwitch input').is(':checked');
        showFuelPartnerTransactionInfo(canPumpAtPartners);
    });

    var counter = $j('.cards-count .number-wrapper input');
    counter.on('input', function(){
        showCardsOrderNavigationTabs();
        var count = parseInt($j('.cards-count .number-wrapper input').val());
        if(count < 1) {
            counter.val(1).trigger('change');
        } else if (count > 50){
            counter.val(50).trigger('change');
        }
        //checkCardsCounter();
    });

    counter.change(function(){
        showCardsOrderNavigationTabs();
    });

    // Event for different cards switches (show information clock in blue wrapper if one of switches is checked)
    var differentCardsTab = $j('.cards-categories .tab-content').find('#diffCards');
    var cardsOutsideSwitchers = differentCardsTab.find('.onoffswitch.outside input');
    var cardsPartnerSwitchers = differentCardsTab.find('.onoffswitch.partner input');
    cardsOutsideSwitchers.change(function(){
        showInternationalTransactionInfo(isSwitchChecked(cardsOutsideSwitchers));
    });
    cardsPartnerSwitchers.change(function(){
        showFuelPartnerTransactionInfo(isSwitchChecked(cardsPartnerSwitchers));
    });

    setCollapseBlockEvent();
}

function setEvents_specialOffers(){
    var favoriteStationBlock = $j('.special-offers .offer').find('.fav-station').find('.point');
    var specialOfferBlock = $j('.special-offers .offer');
    favoriteStationBlock.unbind('DOMSubtreeModified');
    favoriteStationBlock.bind('DOMSubtreeModified', function(){
        if(favStationInfo !== ''){
            specialOfferBlock.find('.btn-red.my-station').attr('disabled', false);
        }
    });

    setCollapseBlockEvent();
}

function setEvents_cardsTechnicalParams(){
    var content = $j('.step-content');
    var cardTechParamsBlock = content.find('.cards-tech-parameters');
    var cardTechParamsItems = cardTechParamsBlock.find('.cards-list .card-item');
    var continueButton = cardTechParamsBlock.find('.btn-red.continue');

    //set company name counter
    counterLenCompanyName();

    var isCardOwnerValid = false;
    var isCompanyValid = false;
    cardTechParamsItems.find('.card-param-value input').on('input', function() {
        var cardTechParams_requiredInputs = $j(this).closest('.card-item').find('.form-control.required');
        checkRequiredFields(cardTechParams_requiredInputs, cardTechParamsBlock.find('.btn-red.save-params'));

        var cardOwnerInput = $j(this);
        var selectedCardOwnerType = cardTechParamsItems.closest('.card-item').find('.card-owner-type').find('[id$="selectDriverNameOrCarNumber"]').attr('class');
        if(!(selectedCardOwnerType == undefined)){
            if(selectedCardOwnerType.toLowerCase() === 'car-number'){
                isCardOwnerValid = isInputValueValid(cardOwnerInput, new RegExp(regs.carNumberFormat_DE));
            }
            if(selectedCardOwnerType.toLowerCase() === 'driver-name'){
                isCardOwnerValid = isInputValueValid(cardOwnerInput, new RegExp(regs.embossingLetters));
            }
        }

        if(!isCardOwnerValid){
            continueButton.attr('disabled', true);
        }
    });

    cardTechParamsItems.find('.company-name input').on('input', function() {
        var cardTechParams_requiredInputs = $j(this).closest('.card-item').find('.form-control.required');
        checkRequiredFields(cardTechParams_requiredInputs, cardTechParamsBlock.find('.btn-red.save-params'));
        var companyInput = $j(this);
        isCompanyValid = isInputValueValid(companyInput, new RegExp(regs.embossingLettersAndNumbers));
        if(!isCompanyValid){
            continueButton.attr('disabled', true);
        }
    });

    setCollapseBlockEvent();
}


function setEvents_directDebit(){
    var content = $j('.step-content');
    var paymentDirectDebitBlock = content.find('.payment-direct-debit');
    var accountHolderInput = paymentDirectDebitBlock.find('.account-holder').find('input');
    accountHolderInput.on('input', function(e){
        isInputValueValid(accountHolderInput, new RegExp(regs.letters));
    });

    var ibanInput = paymentDirectDebitBlock.find('.iban').find('input');
    ibanInput.on('input', function(e){
        isInputValueValid(ibanInput, new RegExp(regs.ibanFormat_DE));
    });

    var swiftInput = paymentDirectDebitBlock.find('.swift').find('input');
    swiftInput.on('input', function(e){
        isInputValueValid(swiftInput, new RegExp(regs.swiftFormat));
    });

    var paymentDirectDebit_requiredInputs = paymentDirectDebitBlock.find('.form-control.required');

    var allAgreements = paymentDirectDebitBlock.find('input[type="checkbox"].form-check-input');
    var confirmedAgreements = [];
    allAgreements.each(function(){
        if($j(this).is(':checked')){
            confirmedAgreements.push(true);
        } else {
            confirmedAgreements.push(false);
        }
    });
    if(confirmedAgreements.indexOf(false) != -1){
        paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
    }

    allAgreements.click(function(){
        confirmedAgreements = [];
        allAgreements.each(function(){
            if($j(this).is(':checked')){
                confirmedAgreements.push(true);
            } else {
                confirmedAgreements.push(false);
            }
        });
        if(confirmedAgreements.indexOf(false) == -1){
            checkRequiredFields(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
        } else {
            paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
        }
    });

    paymentDirectDebit_requiredInputs.keyup(function() {
        if(confirmedAgreements.indexOf(false) == -1){
            checkRequiredFields(paymentDirectDebit_requiredInputs, paymentDirectDebitBlock.find('.btn-red.continue'));
        } else {
            paymentDirectDebitBlock.find('.btn-red.continue').attr('disabled', true);
        }
    });

    setCollapseBlockEvent();
}

function setEvents_bankTransferDebit(){
    var content = $j('.step-content');
    var paymentBankTransferBlock = content.find('.payment-bank-transfer');
    var paymentMethods = paymentBankTransferBlock.find('.category-link');

    var allAgreements = paymentBankTransferBlock.find('input[type="checkbox"].form-check-input');
    var confirmedAgreements = [];
    allAgreements.each(function(){
        if($j(this).is(':checked')){
            confirmedAgreements.push(true);
        } else {
            confirmedAgreements.push(false);
        }
    });

    validBankTransferForm(paymentBankTransferBlock, paymentMethods, confirmedAgreements);

    paymentMethods.change(function() {
        confirmedAgreements = [];
        allAgreements.each(function(){
            if($j(this).is(':checked')){
                confirmedAgreements.push(true);
            } else {
                confirmedAgreements.push(false);
            }
        });

        validBankTransferForm(paymentBankTransferBlock, paymentMethods, confirmedAgreements);
    });

    allAgreements.click(function(){
        confirmedAgreements = [];
        allAgreements.each(function(){
            if($j(this).is(':checked')){
                confirmedAgreements.push(true);
            } else {
                confirmedAgreements.push(false);
            }
        });

        validBankTransferForm(paymentBankTransferBlock, paymentMethods, confirmedAgreements);
    });

    setCollapseBlockEvent();
}

function setEvents_directDebitDeposit(){
    var content = $j('.step-content');
    var directDebitBlock = content.find('.direct-debit-deposit');

    var paymentMethods = directDebitBlock.find('.category-link');
    validDirectDebitForm(directDebitBlock, paymentMethods);

    paymentMethods.change(function() {
        validDirectDebitForm(directDebitBlock, paymentMethods);
    });

    var agreement = directDebitBlock.find('input[type="checkbox"]');
    agreement.click(function(){
        validDirectDebitForm(directDebitBlock, paymentMethods);
    });

    setCollapseBlockEvent();
}

function setEvents_bankTransferNoDeposit(){
    var content = $j('.step-content');
    var bankTransferNoDepositBlock = content.find('.bank-transfer-no-deposit');

    var agreements = bankTransferNoDepositBlock.find('input[type="checkbox"].form-check-input');
    var confirmedAgreements = [];

    agreements.each(function(){
        if($j(this).is(':checked')){
            confirmedAgreements.push(true);
        } else {
            confirmedAgreements.push(false);
        }
    });
    if(confirmedAgreements.indexOf(false) != -1){
        bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', true);
    } else {
        bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', false);
    }

    agreements.click(function(){
        confirmedAgreements = [];
        agreements.each(function(){
            if($j(this).is(':checked')){
                confirmedAgreements.push(true);
            } else {
                confirmedAgreements.push(false);
            }
        });
        if(confirmedAgreements.indexOf(false) != -1){
            bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', true);
        } else {
            bankTransferNoDepositBlock.find('.btn-red.continue').attr('disabled', false);
        }
    });

    setCollapseBlockEvent();
}


function setChatOptions(){
    //First chat init
    setupChatInit();

    //Event to reset active form  for client on form (auto chat call)
    $j(document).on('keydown', function(){resetInActive()});

    //First reset form inactive
    resetInActive();

    //press "Enter" event on offline chat form
    document.getElementById('liveAgentChatTextArea').onkeydown = function(event){
        if(event.keyCode==13){
            updateOfflineChat();
            return false;
        }
    };

    //add language parameter to online chat form submit
    var url = new URL(window.location.href);
    var country = url.searchParams.get("country");
    var elementBody = $j('.modal-open');
    elementBody.bind('DOMSubtreeModified', function(){
        var elementForms = document.getElementsByTagName('form');
        for (var i = 0; i < elementForms.length; i++) {
            if (elementForms[i].target == 'frameChat'){
                if (elementForms[i].action.toString().indexOf('language%3D%23') != -1){
                    elementForms[i].action = elementForms[i].action.replace('language%3D','language%3D'+country);
                }
            }
        }
    });

    //events to offline textarea
    $j('.liveAgentSendButton').hide();
    $j('#liveAgentChatTextArea').focus(function(event){
        if(!$j('.liveAgentSendButton').is(":visible")){
            $j('#liveAgentChatLog').height($j('#liveAgentChatLog').height()-20);
            $j('#liveAgentChatTextArea').height($j('#liveAgentChatTextArea').height()+15);
            $j('.liveAgentSendButton').show();
        }
    });
    $j('#liveAgentChatTextArea').focusout(function(event){
            if($j(event.relatedTarget).hasClass('liveAgentSendButton')){
                 $j('.liveAgentSendButton').show();
            }
            else {
                $j('#liveAgentChatLog').height($j('#liveAgentChatLog').height()+20);
                $j('#liveAgentChatTextArea').height($j('#liveAgentChatTextArea').height()-15);
                $j('.liveAgentSendButton').hide();
            }
    });
    $j('.liveAgentSendButton').on('click', function(){
            $j('#liveAgentChatTextArea').focus();
    });
}

function setupChatInitialization(urlChat, deploymentID, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, mode){
    if(activeStep.toString() == '0'){
        document.getElementById("chat-button-online").style.visibility = "hidden";
        document.getElementById("chat-button-offline").style.visibility = "hidden";
    }
    liveagent.disconnect();
    if (opportunityID != ''){
        liveagent.addCustomDetail("OpportunityID", opportunityID, false).saveToTranscript('Opportunity__c');
        liveagent.findOrCreate("Opportunity").map("ID","OpportunityID",true,true,true).saveToTranscript("OpportunityId").showOnCreate();
        liveagent.addCustomDetail("AccountID", accountID, false).saveToTranscript('AccountID');
        liveagent.findOrCreate("Account").map("ID","AccountID",true,true,true).saveToTranscript("AccountId").showOnCreate();
    }
    if (contactID != ''){
        liveagent.addCustomDetail("ContactID", contactID, false).saveToTranscript('ContactID');
        liveagent.findOrCreate("Contact").map("ID","ContactID",true,true,true).saveToTranscript("ContactId").showOnCreate();
    }
    liveagent.setName(chatFirstMessage);
    liveagent.addCustomDetail("Step", activeStep, false).saveToTranscript('E2E_Step__c');
    liveagent.addCustomDetail("Mode of initialization", mode, false).saveToTranscript('Mode_of_initialization__c');
    liveagent.addCustomDetail("Type of chat", 'online', false).saveToTranscript('Type__c');
    liveagent.init(urlChat, deploymentID, organizationID);
     //Start initialization button for visible online/offline chat
    if(buttonID != ''){
        if (!window._laq) { window._laq = []; }
        window._laq.push(function(){
            liveagent.showWhenOnline(buttonID, document.getElementById("chat-button-online"));
            liveagent.showWhenOffline(buttonID, document.getElementById("chat-button-offline"));
        });
    }
}

function startOnlineChat(urlChat, deploymentID, deploymentJsURL, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, mode){
    delete liveagent;
    delete liveAgentDeployment;
    jQuery.loadScript(deploymentJsURL, function() {
        executeOnlineChat(urlChat, deploymentID, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, mode);
    });
}

jQuery.loadScript = function (url, callback) {
    jQuery.ajax({ url: url,  dataType: 'script', success: callback,  async: true });
};

function executeOnlineChat(urlChat, deploymentID, organizationID, buttonID, contactID, opportunityID, accountID, chatFirstMessage, activeStep, mode){
    if ((document.getElementById("frameChat") == null) && (document.getElementById('chat-button-online').style.display != 'none')) {
        document.getElementById('chat-button-offline').style.visibility = 'hidden';
        document.getElementById('chat-button-online').style.visibility = 'hidden';
        setupChatInitialization(urlChat, deploymentID, organizationID, '', contactID, opportunityID, accountID, chatFirstMessage, activeStep, mode);
        var frameChat = document.createElement("iframe");
        frameChat.id = 'frameChat';
        frameChat.name = 'frameChat';
        frameChat.classList.add('frameChat');
        document.getElementById("chatOnlineBlock").appendChild(frameChat);
        setTimeout(function startChatWithWindow() {
                       try {
                          liveagent.startChatWithWindow(buttonID,'frameChat');
                          document.getElementById('chatOnlineBlock').classList.add('popup-on');
                          setOpportunityFlagChat(mode);
                       }
                       catch (err){
                          document.getElementById('chat-button-offline').style.visibility = 'visible';
                          document.getElementById('chat-button-online').style.visibility = 'visible';
                          document.getElementById('chatOnlineBlock').classList.remove('popup-on');
                          var frameChat = document.getElementById("frameChat");
                          frameChat.remove();
                          var frameChatForms = document.getElementsByTagName('form');
                          for(var i=0; i< frameChatForms.length; i++){
                             if(frameChatForms[i].target == 'frameChat'){
                                  frameChatForms[i].remove();
                             }
                          }
                       }
                  }, 800);
    }
}

function resetInActive(){
    clearTimeout(chatActivityTimeout);
    chatActivityTimeout = setTimeout(inActive, 60000);
}

function inActive(){
    var chatOnlineButton =  document.getElementById('chat-button-online');
    if ((chatOnlineButton.style.display != 'none') && (chatOnlineButton.style.visibility != 'hidden')){
        var frameChatOnline = document.getElementById('frameChat');
        if((frameChatOnline == null) && !($j('#chatOfflineBlock').hasClass('popup-on'))){
            setupOnlineAutoChat();
        }
    }
    resetInActive();
}

function setupOfflineChat(){
    document.getElementById('chat-button-offline').style.visibility = 'hidden';
    document.getElementById('chat-button-online').style.visibility = 'hidden';
    var chatLog = document.getElementById("liveAgentChatLog");
    document.getElementById('chatOfflineBlock').classList.add('popup-on');
    chatLog.scrollTop = chatLog.scrollHeight;
    chatOfflineOLDText = '';
    chatOfflineUpdateTimeout = setTimeout(updateDatabaseOfflineChat, 5000);
}

function updateOfflineChat(){
    var chatTextArea = document.getElementById('liveAgentChatTextArea');
    if (chatTextArea.value != ''){
        var chatLog = document.getElementById('liveAgentChatLogText');
        var currentDate = new Date();
        var hours = currentDate.getHours();
        var minutes = currentDate.getMinutes();
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        chatLog.innerHTML = chatLog.innerHTML + '<span class="chat-client"> <span class="chat-name"> <strong>You </strong>' +
        '<span class="chat-customDateTime" style="display: inline"> ' + strTime + ' </span> </span> <span class="chat-messageText">'+chatTextArea.value+'</span> <span>';
        chatTextArea.value = '';
    }
    var chatLog = document.getElementById("liveAgentChatLog");
    chatLog.scrollTop = chatLog.scrollHeight;
}

function updateDatabaseOfflineChat(){
    var chatLogDbUpdate = $j('.liveAgentChatLogText').html().split('<span class="chat-operator">').join('<br><span class="chat-operator">').split('<span class="chat-client">').join('<br><span class="chat-client">');
    if (chatLogDbUpdate != chatOfflineOLDText){
        chatOfflineOLDText = chatLogDbUpdate;
        saveOfflineChat(chatLogDbUpdate);
        setOpportunityFlagChat('manual');
    }
    clearTimeout(chatOfflineUpdateTimeout);
    chatOfflineUpdateTimeout = setTimeout(updateDatabaseOfflineChat, 5000);
}


function closeChat(status){
    if (status == 'online'){
        document.getElementById('chatOnlineBlock').classList.remove('popup-on');
        var frameChat = document.getElementById("frameChat");
        frameChat.remove();
        var frameChatForms = document.getElementsByTagName('form');
        for(var i=0; i< frameChatForms.length; i++){
            if(frameChatForms[i].target == 'frameChat'){
                frameChatForms[i].remove();
            }
        }
    }
    else if (status == 'offline'){
        document.getElementById('chatOfflineBlock').classList.remove('popup-on');
    }
    document.getElementById('chat-button-offline').style.visibility = 'visible';
    document.getElementById('chat-button-online').style.visibility = 'visible';
    resetInActive();
}

function  startPayment(block){
    var currentStepBlock = $j('.step-content .' + block);
    var isNextStepDisabled = currentStepBlock.find('.btn-red.continue').is('[disabled=disabled]');
    var isValid = false;
    var form = document.getElementById("paymentFormToSubmit");
    if(!isNextStepDisabled){
        form.submit();
        isValid = true;
    }
    return isValid;
}

function updatePaymentMethod(input, textId) {
    document.getElementById(textId).value = input.value;
    changeMethod();
}

function downloadSepaBlock(url){
    document.location.href = url;
}

function changeFieldsInSepa(accHolder, iban, swift, frameID) {
    var sepaFrame = document.getElementById(frameID);
    var sepaFrameDocument = (sepaFrame.contentWindow || sepaFrame.contentDocument);
    if (sepaFrameDocument.document) {
        sepaFrameDocument = sepaFrameDocument.document;
        var dynamicAccountHolder = sepaFrameDocument.getElementById('frameAccountHolder');
        dynamicAccountHolder.innerHTML = accHolder;
        var dynamicIBAN = sepaFrameDocument.getElementById('frameSepaIBAN');
        dynamicIBAN.innerHTML = iban;
        var dynamicSWIFT = sepaFrameDocument.getElementById('frameSepaSWIFT');
        dynamicSWIFT.innerHTML = swift;
    }
}


