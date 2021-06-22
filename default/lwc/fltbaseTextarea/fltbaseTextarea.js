//VERSION - 1.1

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

export default class FltbaseTextarea extends LightningElement {
    @track focused;
    @track checkOnInput;
    @track valid;
    @track _value = '';
    @track _regExp;
    connected;
    timerId;

    @api label;
    @api placeholder;
    @api errorMessage;
    @api required;
    @api maxLength;
    @api inputName;
    @api input;
    @api variant;
    @api size;

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
        return this.valid;
    }

    disconnectedCallback() {
        this.connected = false;
    }

    renderedCallback() {
        if (!this.connected) {
            this.connected = true;
            this.checkOnInput = this._value.length > 0;
            this.input = this.template.querySelector('textarea');
            this.input.value = this._value;
            if (this.checkOnInput) {
                this.setValidity();
            }
        }

        let tooltip = this.querySelector('l-fltbase-tooltip');
        if (tooltip) {
            tooltip.whiteBackground = !this.focused;
        }
    }

    setValidity() {
        if (!this.connected) {
            return;
        }

        this.valid = false;
        let required = normalizeBoolean(this.required);
        let trimmedValue = this._value.trim();

        if (this._regExp) {
            let re = new RegExp(this._regExp);
            this.valid = re.test(trimmedValue);
        } else if (required === true) {
            this.valid = trimmedValue.length > 0;
        } else {
            this.valid = true;
        }
    }

    handleClick(event) {
        this.template.querySelector('textarea').focus();
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
        }
    }

    get computedBlockClass() {
        return configToString({
            'fltbase-textarea__block_auto': this.normalizedSize === SIZES.AUTO,
            'fltbase-textarea__block_small': this.normalizedSize === SIZES.SMALL,
        });
    }

    get computedComponentClass() {
        return configToString({
            'fltbase-textarea': true,
            'fltbase-textarea_gray': this.normalizedVariant === VARIANTS.GRAY,
            'fltbase-textarea_white': this.normalizedVariant === VARIANTS.WHITE,
            'fltbase-textarea_auto': this.normalizedSize === SIZES.AUTO,
            'fltbase-textarea_small': this.normalizedSize === SIZES.SMALL,
            'fltbase-textarea__required': normalizeBoolean(this.required),
            'fltbase-textarea__required_auto': normalizeBoolean(this.required) && this.normalizedSize === SIZES.AUTO,
            'fltbase-textarea__required_small': normalizeBoolean(this.required) && this.normalizedSize === SIZES.SMALL,
            'fltbase-textarea__focused': this.focused,
            'fltbase-textarea__error': !this.valid && this.checkOnInput,
            'fltbase-textarea__empty': this._value.length === 0,
        });
    }

    get computedLabelClass() {
        return configToString({
            'fltbase-textarea__label': true,
            'fltbase-textarea__label-empty': !this.focused && this._value.length === 0,
            'fltbase-textarea__label_auto': this.normalizedSize === SIZES.AUTO,
            'fltbase-textarea__label_small': this.normalizedSize === SIZES.SMALL,
        });
    }

    get computedInputClass() {
        return configToString({
            'fltbase-textarea__input': true,
        });
    }

    get computedErrorMessageClass() {
        return configToString({
            'fltbase-textarea__error-message': true,
            'fltbase-textarea__error-message_auto': this.normalizedSize === SIZES.AUTO,
            'fltbase-textarea__error-message_small': this.normalizedSize === SIZES.SMALL,
        });
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