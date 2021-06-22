$jpd = jQuery.noConflict();
$jpd(document).ready(function() {
    init();
});
function init () {
	putInputMask_Start_AdditionalPhone($jpd('.new-additional-phone-input-mask'));
}
function initAdditionalPhones () {
	$jpd('.edit-additional-phone-input-mask').each(function(){
		defineNumberMask($jpd(this));
	});
}
function initPhoneFields () {
	$jpd('.phone-field-input-mask').each(function(){
		defineNumberMask($jpd(this));
	});
}

function onChangeInputPhoneField (elem) {
   handleChangingOriginalValue (elem);
   handleChangingPreviousValue (elem);
}

function handleChangingOriginalValue (elem) {
	var fieldName = null;
	var classes = elem.classList.value.split(' ');
    for(classIndex = 0; classIndex < classes.length; ++classIndex) {
	    if (classes[classIndex].indexOf('data-') !== -1) {
  		    fieldName = classes[classIndex].split('-')[1];
	    }
    }
    var newValue = $jpd(elem).val();
    var originalFieldValue = $jpd('#' + 'original-val-' + fieldName).text();
    if (newValue != originalFieldValue) {
		$jpd('.' + fieldName + '-statuses').addClass('phone-number-changed');
	} else {
		console.log('original value not changed' );
		$jpd('.' + fieldName + '-statuses').removeClass('phone-number-changed');
	}
}

function handleChangingPreviousValue (elem) {
	var previousVal = $jpd(elem).data('value').toString();
	if ($jpd(elem).val() != previousVal) {
		//console.log('newValue :' + $jpd(elem).val() );
		//console.log('previousVal :' + previousVal);
		var countrycodeChanged = false;
		if ($jpd(elem).val().indexOf('8') == 0 && $jpd(elem).val().substring(0,1) != previousVal.substring(0,1)) {
			countrycodeChanged = true;	
		} else if ($jpd(elem).val().substring(0,2) != previousVal.substring(0,2)) {
			countrycodeChanged = true;	
		}
		if (countrycodeChanged) {
			defineNumberMask(elem);
		}
	}
    $jpd(elem).data('value', $jpd(elem).val()); 
}

function defineNumberMask (elem, RUNumbersOnly) {
	if ($jpd(elem).data('status') == "Needs validation") return;
	//console.log('>>> in >>> define number mask');
	//console.log($jpd(elem).val());
	var savedSelectionStartPosition = elem.selectionStart ? elem.selectionStart : 1;
	if ($jpd(elem).val() == '') {
		//console.log('defined empty - start')
		putInputMask_Start (elem);
	} else if ($jpd(elem).val().indexOf('+7') == 0) {
		//console.log('defined ru +7');
        putInputMaskRU7 (elem);
	} else if ($jpd(elem).val().indexOf('8') == 0) {
		//console.log('defined ru 8');
        putInputMaskRU8 (elem);
	} else if ($jpd(elem).val().indexOf('+8') == 0) {
		//console.log('defined ru +8');
		var numItems = $jpd(elem).val().split('#');
		var numLength = numItems[0].length;
		var extensiomNumber = numItems.length > 1 ? '#'+numItems[1] : '';
		var enteredNum = $jpd(elem).val();
		var newVal = '+' + enteredNum.substring(2, numLength) + extensiomNumber;
		var newVal7 = '+7' + enteredNum.substring(2, numLength > 12 ? 12 : numLength) + extensiomNumber;
		if(numLength == 12) {
			$jpd(elem).val(newVal7) // replace 8 with 7
		} else {
			if (newVal.indexOf('+8') == 0) {
				$jpd(elem).val(newVal7);
			} else {
				$jpd(elem).val(newVal); // remove 8
			}
		}
    } else if ($jpd(elem).val().indexOf('+') == 0) {
		//console.log('defined eu');
        if (RUNumbersOnly == true) replaceEUCodeToRU(elem);
		else putInputMaskEU (elem);
	} else {
		//console.log('wrong number..add+');
		$jpd(elem).val('+'+$jpd(elem).val());
		if (RUNumbersOnly == true) replaceEUCodeToRU(elem);
		else putInputMaskEU (elem);
	}
	elem.selectionStart = savedSelectionStartPosition;
	elem.selectionEnd = savedSelectionStartPosition;
}

function replaceEUCodeToRU (elem) { // dont allow to enter a number in EU format
	var numItems = $jpd(elem).val().split('#');
	var numLength = numItems[0].length;
	var extensiomNumber = numItems.length > 1 ? '#'+numItems[1] : '';
	var enteredNum = $jpd(elem).val();
	var newVal7 = '+7' + enteredNum.substring(2, numLength > 12 ? 12 : numLength) + extensiomNumber;
	$jpd(elem).val(newVal7);
}

var ruMask = "+9{11}[*9{1,5}]";
var ruMask7 = "+79{10}[*9{1,5}]";
var ruMask8 = "9{11}[*9{1,5}]";
var euMask = "+9{8,15}[*9{1,5}]";

var ruPlaceholder = "+___________#___";
var ruPlaceholder7 = "+7__________#___";
var ruPlaceholder8 = "8__________#___";
var euPlaceholder = "+________#___";

function putInputMask_Start_AdditionalPhone (elem) {
    $jpd(elem).val('');
    putInputMask_AdditionalPhone (elem);
}

function putInputMask_Start (elem) {
	$jpd(elem).data('value', $jpd(elem).val());
	if ($jpd(elem).val() == '') {
	   putInputMaskRU7 (elem);
	}
}

function putInputMask_AdditionalPhone (elem) {
	$jpd(elem).inputmask({
		mask: ruMask7,
		greedy: false,
		definitions: {
		  '*': {
			validator: "[#]",
			casing: "lower"
		  }
		},
		placeholder: ruPlaceholder7
	});
}
function putInputMaskRU7 (elem) {
	$jpd(elem).inputmask({
		mask: ruMask,
		greedy: false,
		definitions: {
		  '*': {
			validator: "[#]",
			casing: "lower"
		  }
		},
		placeholder: ruPlaceholder
	});
}
function putInputMaskRU8 (elem) {
	$jpd(elem).inputmask({
		mask: ruMask8,
		greedy: false,
		definitions: {
		  '*': {
			validator: "[#]",
			casing: "lower"
		  }
		},
		placeholder: ruPlaceholder8
	});
}
function putInputMaskEU (elem) {
	$jpd(elem).inputmask({
		mask: euMask,
		greedy: false,
		definitions: {
		  '*': {
			validator: "[#]",
			casing: "lower"
		  }
		},
		placeholder: euPlaceholder
	});
}
function isValidPhoneFormatRU (elem) {
	if($jpd(elem).val().indexOf('_') != -1) {
		return false;
	}
	return true;
}
