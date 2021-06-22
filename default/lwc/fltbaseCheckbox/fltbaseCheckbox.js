//VERSION - 1.1

import { LightningElement, api, track } from 'lwc';
import { normalizeString, normalizeBoolean, configToString } from './helper';

const ATTRIBUTES = {
    VARIANT: {
        GRAY: 'gray',
        WHITE: 'white'
    }
};

export default class FltbaseCheckbox extends LightningElement {
    @track error;

    @api label = '';
    @api checked;
    @api variant;
    @api disabled;
    @api required;
    @api isClickHandler;
    @api detailForClickHandler;
    @api errorMessage;

    @api getValidity() {
        this.error = normalizeBoolean(this.required) ? !this.checked : false;
        return !this.error;
    }

    @api get value() {
        return this.checked;
    }

    @api hideError() {
        this.error = false;
    }

    @api showError() {
        this.error = true;
    }

    connectedCallback() {
        this.checked = normalizeBoolean(this.checked);
    }

    renderedCallback() {
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        this.template.querySelector('div').innerHTML = this.label;

        if (this.isClickHandler) {
            const elements = this.template.querySelectorAll('a');
            for (let i = 0; i < elements.length; i++) {
                const item = elements[i];
                if (item.classList.contains('fltbase-checkbox__label-button')) {
                    item.onclick = (event) => {
                        event.preventDefault();
                        this.dispatchEvent(new CustomEvent('fltbasecheckboxlinkpressed', {
                            detail: {
                                type: this.detailForClickHandler,
                                index: i
                            },
                            bubbles: true
                        }));
                    }
                }
            }
        }
    }

    handleChange(event) {
        this.error = false;
        this.checked = event.target.checked;
        this.dispatchEvent(new CustomEvent('fltbasecheckbox', { detail: this.checked, bubbles: true }));
    }

    get computedSpanClass() {
        return configToString({
            'fltbase-checkbox-span': true,
            'fltbase-checkbox-span_gray': this.normalizedVariant === ATTRIBUTES.VARIANT.GRAY,
            'fltbase-checkbox-span_white': this.normalizedVariant === ATTRIBUTES.VARIANT.WHITE,
            'fltbase-checkbox-span_required': normalizeBoolean(this.required),
            'fltbase-checkbox-span_error': normalizeBoolean(this.error),
        });
    }

    get computedErrorClass() {
        return configToString({
            'fltbase-checkbox__error-message': true,
            'fltbase-checkbox__error-message_active': normalizeBoolean(this.error),
        });
    }

    get normalizedVariant() {
        return normalizeString(this.variant, {
            fallbackValue: ATTRIBUTES.VARIANT.GRAY,
            validValues: [
                ATTRIBUTES.VARIANT.GRAY,
                ATTRIBUTES.VARIANT.WHITE,
            ]
        });
    }
}