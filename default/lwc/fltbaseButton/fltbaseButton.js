//VERSION - 1.0

/* eslint-disable no-console */
import {LightningElement, api} from 'lwc';
import { normalizeString, configToString } from './helper';

const ATTRIBUTES = {
    SIZE: {
        SMALL: 'small',
        MEDIUM: 'medium',
        LARGE: 'large',
    },
    VARIANT: {
        BLUE: 'blue',
        GOLD: 'gold',
        GRAY: 'gray',
        SALESFORCE: 'salesforce'
    }
}

export default class FltbaseButton extends LightningElement {
    @api styleClass;
    @api disabled;
    @api size;
    @api variant;
    @api href;

    connectedCallback () {
        this.template.addEventListener('click', event => {
            if (this.disabled) {
                event.preventDefault();
                event.stopImmediatePropagation();
            }
        });
    }

    get computedButtonClass () {
        
        let config = {
            'fltbase-button-disabled': this.disabled,
            'fltbase-button-required': this.required,
            'fltbase-button-size_small': this.normalizedSize === ATTRIBUTES.SIZE.SMALL,
            'fltbase-button-size_medium': this.normalizedSize === ATTRIBUTES.SIZE.MEDIUM,
            'fltbase-button-size_large': this.normalizedSize === ATTRIBUTES.SIZE.LARGE,
            'fltbase-button-variant_base': true,
            'fltbase-button-variant_blue': this.normalizedVariant === ATTRIBUTES.VARIANT.BLUE,
            'fltbase-button-variant_gold': this.normalizedVariant === ATTRIBUTES.VARIANT.GOLD,
            'fltbase-button-variant_gray': this.normalizedVariant === ATTRIBUTES.VARIANT.GRAY,
            'fltbase-button-variant_salesforce': this.normalizedVariant === ATTRIBUTES.VARIANT.SALESFORCE,
        };
        
        config[this.styleClass] = this.styleClass;
        return configToString(config);
    }

    get computedHref () {
        return this.href;
    }

    get normalizedSize () {
        return normalizeString(this.size, {
            fallbackValue: ATTRIBUTES.SIZE.MEDIUM,
            validValues: [
                ATTRIBUTES.SIZE.SMALL,
                ATTRIBUTES.SIZE.MEDIUM,
                ATTRIBUTES.SIZE.LARGE,
            ]
        });
    }

    get normalizedVariant () {
        return normalizeString(this.variant, {
            fallbackValue: ATTRIBUTES.VARIANT.BLUE,
            validValues: [
                ATTRIBUTES.VARIANT.BLUE,
                ATTRIBUTES.VARIANT.GOLD,
                ATTRIBUTES.VARIANT.GRAY,
                ATTRIBUTES.VARIANT.SALESFORCE,
            ]
        });
    }

}