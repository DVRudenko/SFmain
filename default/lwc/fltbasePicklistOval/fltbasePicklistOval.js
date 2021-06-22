//VERSION - 1.0

import { LightningElement, api, track } from 'lwc';
import { normalizeInteger, normalizeBoolean, configToString } from './helper';

export default class FltbasePicklistOval extends LightningElement {
    @track _selectedValue;
    @track active;
    
    @api label;
    @api dropdownHeight;
    @api options;
    @api required;
    
    @api 
    get selectedValue () {
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
    set selectedValue (value) {
        this._selectedValue = value;
    }

    @api 
    get value () {
        return this.selectedValue;
    }

    @api
    getValidity() {
        return this.required ? this.selectedValue !== null : true;
    }

    handleClick () {
        this.active = !this.active;
    }

    handleSelect (event) {
        let index = normalizeInteger(event.currentTarget.dataset.index);
        if ((index || index === 0) && index >= 0 && index < this.options.length) {
            this._selectedValue = this.options[index].value;
            this.dispatchEvent(new CustomEvent('change', {detail: {
                value: this._selectedValue
            }}));
        }
    }

    handleBlur () {
        this.active = false;
    }

    get selectedLabel () {
        let label;
        if (this.options && this.options.length > 0) {
            this.options.forEach(next => {
                if (this._selectedValue === next.value) {
                    label = next.label;
                }
            });
        }

        if (!label) {
            let notEmpty = this.options && this.options.length > 0;
            label = notEmpty ? this.options[0].label : '-- chose --';
        }
        return label;
    }

    get optionsList () {
        let arr = this.options ? this.options : [];
        arr = JSON.parse( JSON.stringify(arr) );
        arr.forEach((next, index) => {
            next.active = next.value === this._selectedValue;
            next.index = index;
        });
        return arr;
    }

    get computedComponentClass () {
        return configToString({
            'fltbase-picklist-square': true,
            'fltbase-picklist-square_active': this.active,
            'fltbase-picklist-square_required': normalizeBoolean(this.required),
        });
    }

    get computedLabelClass () {
        return configToString({
            'fltbase-picklist-square__label': true,
            'fltbase-picklist-square__label_title': true,
        });
    }

    get computedSelectedLabelClass () {
        return configToString({
            'fltbase-picklist-square__label': true,
            'fltbase-picklist-square__label_value': true,
            
        });
    }

    get computedDropdownClass () {
        return configToString({
            'fltbase-picklist-square__dropdown': true,
            'fltbase-picklist-square__dropdown-active': this.active,
        });
    }

    get computedDropdownStyle () {
        let height = normalizeInteger(this.dropdownHeight);
        let value = height ? height + 'px' : 'auto';
        return `max-height: ${value};`;
    }
}