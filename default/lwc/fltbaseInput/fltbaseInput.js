//VERSION - 1.2

import { LightningElement, api, track } from 'lwc';
import { normalizeBoolean, normalizeInteger, normalizeString, configToString } from './helper';

const VARIANTS = {
    GRAY: 'gray',
    WHITE: 'white'
};

const SIZES = {
    AUTO: 'auto',
    SMALL: 'small'
};

export default class FltbaseInput extends LightningElement {
    @track focused;
    @track checkOnInput;
    @track valid;
    @track warning;
    @track warningMessage;
    @track _value = '';
    @track _regExp;
    connected;
    timerId;

    @api startCheck;
    @api label;
    @api type = "text";
    @api errorMessage;
    @api required;
    @api maxLength;
    @api minValue;
    @api maxValue;
    @api inputName;
    @api input;
    @api variant;
    @api size;
    @api autocompleteDisabled = false;

    @api
    get regExp() {
        return this._regExp;
    }
    set regExp(newValue) {
        this._regExp = newValue;
        this.setValidity();
    }

    @api
    get value() {
        return this._value.trim();
    }
    set value(value) {
        this._value = ['number', 'string'].includes(typeof value) ? value + '' : '';
        this.setValidity();
        if (this.input) {
            this.input.value = this._value;
        }
    }

    @api
    getValidity() {
        this.checkOnInput = true;
        this.setValidity();
        return this.valid && !this.apiError;
    }

    @api 
    showError(){
        this.valid = false;
        this.apiError = true;
        this.warning = false;
    }

    @api 
    showWarning(warningMessage){
        this.warning = this.getValidity();
        if(this.warning){
            this.warningMessage = warningMessage;
        }
    }

    @api 
    hideError(){
        this.warning = false;
        this.valid = true;
        this.apiError = false;
    }

    disconnectedCallback() {
        this.connected = false;
    }

    renderedCallback() {
        if (!this.connected) {
            this.connected = true;
            this.checkOnInput = this.startCheck || this._value.length > 0;
            this.input = this.template.querySelector('input');
            this.input.value = this._value;
            if (this.checkOnInput) {
                this.setValidity();
            }
        }

        let tooltip = this.querySelector('l-fltbase-tooltip');
        if (tooltip && this.normalizedVariant !== VARIANTS.WHITE) {
            tooltip.whiteBackground = !this.focused;
        }
    }

    setValidity() {
        if (!this.connected) {
            return;
        }

        this.valid = false;
        this.warning = false;
        let required = normalizeBoolean(this.required);
        let trimmedValue = this._value.trim();

        if (this.minValue && this.maxValue) {
            let normalizedIntegerValue = normalizeInteger(this._value);
            let minValue = normalizeInteger(this.minValue);
            let maxValue = normalizeInteger(this.maxValue);
            this.valid = normalizedIntegerValue && normalizedIntegerValue >= minValue && normalizedIntegerValue <= maxValue;   
        } else if (this._regExp && trimmedValue.length > 0) {
            let re = new RegExp(this._regExp);
            this.valid = re.test(trimmedValue);
        } else if (required === true) {
            this.valid = trimmedValue.length > 0;
        }  else {
            this.valid = true;
        }
    }

    handleClick(event) {
        this.template.querySelector('input').focus();
    }

    handleFocus(event) {
        this.focused = true;
        clearTimeout(this.timerId);
        this.dispatchEvent(new CustomEvent('focuse'));
    }

    handleBlur() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timerId = setTimeout(() => {
            this.focused = false;
            this.checkOnInput = true;
            this.setValidity();
        }, 100);
        this.dispatchEvent(new CustomEvent('blur'));
    }

    handleInput(event) {
        this._value = event.target.value;
        if (this.checkOnInput) {
            this.setValidity();
            if(!this.valid){
                this.warning = false;
            }
        }
    }

    get computedBlockClass() {
        return configToString({
            'fltbase-input__block_auto': this.normalizedSize === SIZES.AUTO,
            'fltbase-input__block_small': this.normalizedSize === SIZES.SMALL,
        });
    }

    get computedComponentClass() {
        return configToString({
            'fltbase-input': true,
            'fltbase-input_gray': this.normalizedVariant === VARIANTS.GRAY,
            'fltbase-input_white': this.normalizedVariant === VARIANTS.WHITE,
            'fltbase-input_auto': this.normalizedSize === SIZES.AUTO,
            'fltbase-input_small': this.normalizedSize === SIZES.SMALL,
            'fltbase-input__required': normalizeBoolean(this.required),
            'fltbase-input__required_auto': normalizeBoolean(this.required) && this.normalizedSize === SIZES.AUTO,
            'fltbase-input__required_small': normalizeBoolean(this.required) && this.normalizedSize === SIZES.SMALL,
            'fltbase-input__focused': this.focused,
            'fltbase-input__error': !this.valid && this.checkOnInput || this.apiError,
            'fltbase-input__empty': this._value.length === 0,
            'fltbase-input__warning': this.warning,
        });
    }

    get computedLabelClass() {
        return configToString({
            'fltbase-input__label': true,
            'fltbase-input__label-empty': !this.focused && this._value.length === 0,
            'fltbase-input__label_auto': this.normalizedSize === SIZES.AUTO,
            'fltbase-input__label_small': this.normalizedSize === SIZES.SMALL,
        });
    }

    get computedInputClass() {
        return configToString({
            'fltbase-input__input': true,
        });
    }

    get computedErrorMessageClass() {
        return configToString({
            'fltbase-input__error-message': true,
            'fltbase-input__warning-message': this.warning,
            'fltbase-input__error-message_auto': this.normalizedSize === SIZES.AUTO,
            'fltbase-input__error-message_small': this.normalizedSize === SIZES.SMALL,
        });
    }

    get autocomplete () {
        return this.autocompleteDisabled ? 'nope' : '';
    }

    get normalizedVariant() {
        return normalizeString(this.variant, {
            fallbackValue: VARIANTS.GRAY,
            validValues: [
                VARIANTS.GRAY,
                VARIANTS.WHITE,
            ]
        });
    }

    get normalizedSize() {
        return normalizeString(this.size, {
            fallbackValue: SIZES.AUTO,
            validValues: [
                SIZES.AUTO,
                SIZES.SMALL,
            ]
        });
    }
}