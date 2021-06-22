//VERSION - 1.0

import { LightningElement, api } from 'lwc';

export default class FltbaseCheckboxToggle extends LightningElement {
    checked;

    @api labelLeft = "L";
    @api labelRight = "R";
    @api valueLeft;
    @api valueRight;

    @api
    get valueSelected () {
        return this.checked ? this.valueRight : this.valueLeft;
    }
    set valueSelected (value) {
        this.checked = value === this.valueRight;
    }

    @api get value () {
        return this.valueSelected;
    }

    handleChange (event) {
        this.checked = event.target.checked;
        this.dispatchEvent(new CustomEvent('change'));
    }

    renderedCallback(){
        this.template.querySelector('.fltbase-toggle-label__left').innerHTML = this.labelLeft;
        this.template.querySelector('.fltbase-toggle-label__right').innerHTML = this.labelRight;
    }
}