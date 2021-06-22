import { api, track, LightningElement, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CREDIT_FACTORY_CALCULATION_OBJECT from '@salesforce/schema/Credit_Factory_Calculation__c';
import COUNTRY_FIELD from '@salesforce/schema/Credit_Factory_Calculation__c.Country__c';
import PAYMENT_DETAIL_FIELD from '@salesforce/schema/Credit_Factory_Calculation__c.Payment_Detail__c';
import DEPOSIT_REASON_FIELD from '@salesforce/schema/Credit_Factory_Calculation__c.Deposit_Reason__c';

const PICKLIST_FIELD_TYPE = 'picklist';
const TEXT_FIELD_TYPE = 'text';
const CHECKBOX_FIELD_TYPE = 'checkbox';

const additionalFieldsToDisplay = {
    Deposit_Reason__c: { key: 'Deposit_Reason__c', label: 'Deposit Reason', value: '', picklistvalues: '', disabled: true }
};

const RECORD_SETTINGS = {
    Class_Rating__c: {
        pattern: /^[0-9]{1,2}$|^[*]$/,
        pattern_message: 'This field should consist a whole number or *'
    },
    Date_of_Foundation_month__c: {
        pattern: /^(<|<=|=|>|>=)\d{1,3}$|^[*]{1}$/,
        pattern_message: 'This field should start with (<, <=, =, >=, >) and end with a number (example: <=18), or *'
    },
    Number_of_Cards__c: {
        pattern: /^(<|<=|=|>|>=)\d{1,3}$|^[*]{1}$/,
        pattern_message: 'This field should start with (<, <=, =, >=, >) and end with a number (example: <=18), or *'
    },
    Total_Consumption_Min_Value__c: {
        pattern: /^(\d{1,7}|[*]{1})$/,
        pattern_message: 'This field should consist a whole number or *'
    },
    Total_Consumption_Max_Value__c: {
        pattern: /^(\d{1,7}|[*]{1})$/,
        pattern_message: 'This field should consist a whole number or *'
    },    
    Security_Level__c: {
        pattern: /^(\d{0,3}|[*]{1})$/,
        pattern_message: 'This field should consist a whole number, * or should be empty'    
    }
}


export default class AddCreditFactoryCalculationModal extends LightningElement {
    fieldsToDisplay = [
        { key: 'Class_Rating__c', label: 'Class Rating', value: '', picklistvalues: '', type: TEXT_FIELD_TYPE, required: true },
        { key: 'Date_of_Foundation_month__c', label: 'Date of Foundation (month)', value: '', picklistvalues: '', type: TEXT_FIELD_TYPE, required: true },
        { key: 'Country__c', label: 'Country', value: '', picklistvalues: '', type: PICKLIST_FIELD_TYPE, required: true },
        { key: 'Payment_Detail__c', label: 'Payment Detail', value: '', picklistvalues: '', type: PICKLIST_FIELD_TYPE, required: true },
        { key: 'Number_of_Cards__c', label: 'Number of Cards', value: '', picklistvalues: '', type: TEXT_FIELD_TYPE, required: true },
        { key: 'Total_Consumption_Min_Value__c', label: 'Total Consumption Min Value', value: '', picklistvalues: '', type: TEXT_FIELD_TYPE, required: true },
        { key: 'Total_Consumption_Max_Value__c', label: 'Total Consumption Max Value', value: '', picklistvalues: '', type: TEXT_FIELD_TYPE, required: true },
        { key: 'Security_Level__c', label: 'Security Level', value: '', picklistvalues: '', type: TEXT_FIELD_TYPE, required: false },
        { key: 'New_Business_Exception__c', label: 'Set 0-EX rating', value: '', picklistvalues: '', type: CHECKBOX_FIELD_TYPE, required: false },
        { key: 'High_Risk__c', label: 'High Risk', value: '', picklistvalues: '', type: CHECKBOX_FIELD_TYPE, required: false }
    ];

    @track modalClass = "slds-modal";
    @track modalBgc = "slds-backdrop";
    @track isModalOpen = false;
    @track textFields;
    @track picklistFields;
    @track checkboxFields;
    @track calculation = {};
    @track picklistFieldsValuesMap = new Map();
    @track fieldsToSave;
    @track depositReason = {};

    @wire(getObjectInfo, {objectApiName: CREDIT_FACTORY_CALCULATION_OBJECT})
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_FIELD})
    wiredPicklistValuesCountry({error, data}) {
        if (data) {
            this.picklistFieldsValuesMap.set('Country__c', data);
        } else if (error) {
            console.log('Error with Country__c field');
        }
    
        this.init();
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PAYMENT_DETAIL_FIELD})
    wiredPicklistValuesPaymentDetail({error, data}) {
        if (data) {
            this.picklistFieldsValuesMap.set('Payment_Detail__c', data);
        } else if (error) {
            console.log('Error with Payment_Detail__c field');
        }

        this.init();
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DEPOSIT_REASON_FIELD})
    wiredPicklistValuesDepositReason({error, data}) {
        if (data) {
            this.picklistFieldsValuesMap.set('Deposit_Reason__c', data);
        } else if (error) {
            console.log('Error with Deposit_Reason__c field');
        }

        this.init();
    }

    connectedCallback() {
        this.init();
    }

    init() {
        if (this.fieldsToDisplay && 
            this.picklistFieldsValuesMap.has('Country__c') && 
            this.picklistFieldsValuesMap.has('Payment_Detail__c') && 
            this.picklistFieldsValuesMap.has('Deposit_Reason__c')) {
            for (let i = 0; i < this.fieldsToDisplay.length; i++) {
                let field = Object.assign({}, this.fieldsToDisplay[i]);
                if (field.type === PICKLIST_FIELD_TYPE) {
                    if (this.picklistFields === undefined) {
                        this.picklistFields = [];
                    }
    
                    field.picklistvalues = this.picklistFieldsValuesMap.get(field.key);

                    this.picklistFields.push(field);
                }
                else if (field.type === TEXT_FIELD_TYPE) {
                    if (this.textFields === undefined) {
                        this.textFields = [];
                    }
    
                    this.textFields.push(field);
                }
                else if (field.type === CHECKBOX_FIELD_TYPE) {
                    if (this.checkboxFields === undefined) {
                        this.checkboxFields = [];
                    }

                    this.checkboxFields.push(field);
                }
            }

            this.depositReason = additionalFieldsToDisplay['Deposit_Reason__c'];
            this.depositReason.picklistvalues = this.picklistFieldsValuesMap.get('Deposit_Reason__c');
        }
    }

    @api
    closeModal() {
        this.calculation = undefined;
        this.textFields.forEach(input => {
            input.value = null;
        });
        this.picklistFields.forEach(input => {
            input.value = null;
        });

        this.modalClass = "slds-modal";
        this.modalBgc = "slds-backdrop";
        this.isModalOpen = false;
    }

    @api
    showModal() {
        if (this.calculation === undefined) {
            this.calculation = {};
        }

        this.modalClass = "slds-modal slds-fade-in-open";
        this.modalBgc = "slds-backdrop slds-fade-in-open";
        this.isModalOpen = true;
    }

    @api
    setCalculation(calculation) {
        this.calculation = calculation;
        for (let i = 0; i < this.textFields.length; i++) {
            this.textFields[i].value = calculation[this.textFields[i].key];
        }

        for (let i = 0; i < this.picklistFields.length; i++) {
            this.picklistFields[i].value = calculation[this.picklistFields[i].key];
        }

        for (let i = 0; i < this.checkboxFields.length; i++) {
            this.checkboxFields[i].value = calculation[this.checkboxFields[i].key];
        }

        this.setAdditionalFields();
    }

    setAdditionalFields() {
        this.depositReason.value = this.calculation['Deposit_Reason__c'];
        this.depositReason.disabled = true;
        this.depositReason.required = false;
        if (this.calculation.hasOwnProperty('Security_Level__c')) {
            let pattern = /^(\d{1,3})$/;
            let value = this.calculation['Security_Level__c'];
            if (value.match(pattern)) {
                this.depositReason.disabled = false;
                this.depositReason.required = true;
            }
        }
    }

    saveCalculation() { 
        let newCalculation = {};
        let isValid = true;
        this.template.querySelectorAll(".calculation-field").forEach(input => {
            if (input.type === 'checkbox') {
                newCalculation[input.name] = input.checked;
            }
            else {
                newCalculation[input.name] = input.value;
            }
            
            if (! input.checkValidity() && isValid) {
                isValid = false;
            }
        });

        if (! isValid) {
            alert('Fill required fields with valid data');
            return;
        }

        if (this.calculation.isNew) {
            this.dispatchEvent(
                new CustomEvent("newcalculation", {
                    detail: newCalculation,
                    bubbles: true
                })
            );
        } else {
            let isFieldChanged;
            newCalculation.Id = this.calculation.Id;
            newCalculation.Order__c = this.calculation.Order__c;
            for (let key in this.calculation) {
                if (newCalculation[key] != this.calculation[key]) {
                    isFieldChanged = true;
                    break;
                }
            }

            if (Object.keys(this.calculation).length != Object.keys(newCalculation).length && !isFieldChanged) {
                isFieldChanged = true;
            }

            if (isFieldChanged) {
                this.dispatchEvent(
                    new CustomEvent("editcalculation", {
                        detail: newCalculation,
                        bubbles: true
                    })
                );
            }
        }
        
        this.closeModal();
    }

    handlePicklistValue(event) {
        
    }

    handleInputValue(event) {
        if (event.target.name === 'Security_Level__c') {
            this.validateDepositReason(event.target);
        }

        let validation = RECORD_SETTINGS[event.target.name];
        if (! event.target.value.match(validation.pattern)) {
            event.target.setCustomValidity(validation.pattern_message);
        }
        else {
            event.target.setCustomValidity('');
        }

        event.target.reportValidity();
    }

    validateDepositReason(field) {
        let pattern = /^(\d{1,3})$/;
        let depositReason = this.template.querySelector('.deposit-reason-field');
        if (field.value.match(pattern)) {
            depositReason.disabled = false;
            depositReason.required = true;
        }
        else {
            depositReason.disabled = true;
            depositReason.required = false;
            depositReason.value = '';
            depositReason.setCustomValidity('');
            depositReason.reportValidity();
        }
    }
}