//VERSION - 1.2

import { LightningElement, api, track } from 'lwc';
import { normalizeString, normalizeInteger, configToString } from './helper';

const ATTRIBUTES = {
    OPTION_HEIGHT: 40,
    DIRECTION: {
        TOP: 'top',
        BOTTOM: 'bottom'
    },
    VARIANT: {
        GRAY: 'gray',
        BLACK: 'black'
    }
};

export default class FltbasePicklistSquare extends LightningElement {

    @track _selectedValue;
    @track active;

    @api dropdownLength;
    @api droppingDirection;
    @api options;
    @api variant;
    @api hideNone;
    @api withIcons;

    @api
    get selectedValue() {
        let value;
        if (this.options && this.options.length > 0) {
            this.options.forEach(next => {
                if (this._selectedValue === next.value) {
                    value = next.value;
                }
            });
        }

        if (!value) {
            let notEmpty = this.options && this.options.length > 0;
            value = notEmpty ? this.options[0].value : null;
        }

        return value;
    }
    set selectedValue(value) {
        this._selectedValue = value;
    }

    toggleMemuHandler(){
        this.active = !this.active;
    }

    selectMenuItemHandler(event){
        const index = event.currentTarget.dataset.index;
        this._selectedValue = this.options[index].value;
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                value: this._selectedValue
            }
        }));
    }

    blurHandle() {
        this.active = false;
    }

    get selectedItem() {
        let label, icon;
        if (this.options && this.options.length > 0) {
            this.options.forEach(next => {
                if (this._selectedValue === next.value) {
                    label = next.label;
                    icon = next.icon;
                }
            });
        }

        if (!label) {
            let notEmpty = this.options && this.options.length > 0;
            label = notEmpty ? this.options[0].label : this.hideNone ? '' : '-- none --';
        }
        return {
            label:label,
            icon: icon
        };
    }

    get optionsList() {
        let arr = this.options ? this.options : [];
        arr = JSON.parse(JSON.stringify(arr));
        arr.forEach((next, index) => {
            next.active = next.value === this._selectedValue;
            next.index = index;
        });
        return arr;
    }

    get computedPicklistClass() {
        return configToString({
            'fltbase-picklist-square': true,
            'fltbase-picklist-square__active': this.active,
            'fltbase-picklist-square__variant-gray': this.normalizedVariant === ATTRIBUTES.VARIANT.GRAY,
            'fltbase-picklist-square__variant-black': this.normalizedVariant === ATTRIBUTES.VARIANT.BLACK
        });
    }

    get computedDropdownClass() {
        return configToString({
            'fltbase-picklist-square__dropdown': true,
            'fltbase-picklist-square__dropdown-active': this.active,
            'fltbase-picklist-square__dropdown-direction_top': this.normalizedDirection === ATTRIBUTES.DIRECTION.TOP,
            'fltbase-picklist-square__dropdown-direction_bottom': this.normalizedDirection === ATTRIBUTES.DIRECTION.BOTTOM,
        });
    }

    get computedDropdownOptionClass() {
        return configToString({
            'fltbase-picklist-square__dropdown-option': true,
            'fltbase-picklist-square__text-overflow': true,
        });
    }

    get computedDropdownStyle() {
        let length = normalizeInteger(this.dropdownLength);
        let value = length ? (ATTRIBUTES.OPTION_HEIGHT * length) + 'px' : 'auto';
        return `max-height: ${value};`;
    }

    get normalizedDirection() {
        return normalizeString(this.droppingDirection, {
            fallbackValue: ATTRIBUTES.DIRECTION.BOTTOM,
            validValues: [
                ATTRIBUTES.DIRECTION.TOP,
                ATTRIBUTES.DIRECTION.BOTTOM,
            ]
        });
    }

    get normalizedVariant() {
        return normalizeString(this.variant, {
            fallbackValue: ATTRIBUTES.VARIANT.GRAY,
            validValues: [
                ATTRIBUTES.VARIANT.GRAY,
                ATTRIBUTES.VARIANT.BLACK,
            ]
        });
    }
}