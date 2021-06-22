import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCalculations from '@salesforce/apex/CreditFactoryCalculationCtrl.getCalculations';
import upsertCalculations from '@salesforce/apex/CreditFactoryCalculationCtrl.upsertCalculations';
import deleteCalculations from '@salesforce/apex/CreditFactoryCalculationCtrl.deleteCalculations';
import CREDIT_FACTORY_CALCULATION_OBJECT from '@salesforce/schema/Credit_Factory_Calculation__c';
import COUNTRY_FIELD from '@salesforce/schema/Credit_Factory_Calculation__c.Country__c';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
    { label: 'Clone', name: 'clone' },
    { label: 'Move Up', name: 'moveup' },
    { label: 'Move Down', name: 'movedown' }
];

const columns = [
    { label: 'Order', fieldName: 'Order__c', initialWidth: 70, hideDefaultActions: true},
    { label: 'Class Rating', fieldName: 'Class_Rating__c', initialWidth: 100, hideDefaultActions: true },
    { label: 'Number of Cards', fieldName: 'Number_of_Cards__c', initialWidth: 150, hideDefaultActions: true },
    { label: 'Date of Foundation (months)', fieldName: 'Date_of_Foundation_month__c', hideDefaultActions: true },
    { label: 'Total Consumption Min Value', fieldName: 'Total_Consumption_Min_Value__c', hideDefaultActions: true },
    { label: 'Total Consumption Max Value', fieldName: 'Total_Consumption_Max_Value__c', hideDefaultActions: true },
    { label: 'Payment Detail', fieldName: 'Payment_Detail__c', initialWidth: 120, hideDefaultActions: true },
    { label: 'Security Level', fieldName: 'Security_Level__c', initialWidth: 120, hideDefaultActions: true },
    { label: 'Deposit Reason', fieldName: 'Deposit_Reason__c', initialWidth: 190, hideDefaultActions: true },
    { label: '0-EX', fieldName: 'New_Business_Exception__c', type: 'boolean', initialWidth: 50,  hideDefaultActions: true },
    { label: 'High Risk', fieldName: 'High_Risk__c', type: 'boolean', initialWidth: 85,  hideDefaultActions: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    }
];

const TOAST_SUCCESS_MESSAGE = 'The data has been sucessfully updated';
const TOAST_ERROR_MESSAGE = 'An error occured while updating the data';

export default class CreditFactoryCalculation extends LightningElement {
    columns = columns;

    @track country;
    @track loading;
    @track options;
    @track calculationsForAllCountriesMap = {};
    @track error;
    @track calculationsForAllCountriesMapCopy;
    @track calculationsIdToDelete = [];

    @wire(getObjectInfo, {objectApiName: CREDIT_FACTORY_CALCULATION_OBJECT})
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_FIELD})
    getPicklistValues({error, data}) {
        if (data) {
            this.options = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });
        } else if (error) {
            console.log('Error with Country__c field');
        }
    }


    connectedCallback() {
        this.init();
    }


    get calculationsForCountry() {
        let calculationsForCountry = [];
        if (this.calculationsForAllCountriesMap[this.country]) {
            calculationsForCountry = this.calculationsForAllCountriesMap[this.country];
            calculationsForCountry.map((n, index) => {
                n.Order__c = index + 1;
                return n;
            });
        }
        
        return calculationsForCountry;
    }

    
    async init() {
        document.title = 'Credit Factory Calculations';
        this.loading = true;
        await getCalculations()
            .then(result => {
                this.calculationsForAllCountriesMap = JSON.parse(JSON.stringify(result));
            })
            .catch(error => {
                this.error = error;
            });
        this.loading = false;    
    }


    handleCountryChange(event) {
        this.country = event.detail.value;
    }


    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.editRow(row);
                break;
            case 'delete':
                this.deleteRow(row);
                break;
            case 'clone':
                this.cloneRow(row);
                break;    
            case 'moveup':
                this.moveRowUp(row);
                break;
            case 'movedown':
                this.moveRowDown(row);
                break;    
            default:
        }
    }


    editRow(row) {
        const modal = this.template.querySelector("c-add-credit-factory-calculation-modal");
        row.isNew = false;
        if (modal) {
            modal.setCalculation(row);
            modal.showModal();
        }
    }


    deleteRow(row) {
        let index = row.Order__c - 1;

        if (! this.calculationsForAllCountriesMapCopy) {
            this.calculationsForAllCountriesMapCopy = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
        }

        if (this.calculationsForAllCountriesMap[this.country][index].Id) {
            this.calculationsIdToDelete.push(this.calculationsForAllCountriesMap[this.country][index].Id);
        }
        
        this.calculationsForAllCountriesMap[this.country].splice(index, 1);
        this.calculationsForAllCountriesMap[this.country] = this.calculationsForCountry;
        this.calculationsForAllCountriesMap = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
    }


    cloneRow(row) {
        const modal = this.template.querySelector("c-add-credit-factory-calculation-modal");
        row.isNew = true;
        if (modal) {
            modal.setCalculation(row);
            modal.showModal();
        }
    }


    moveRowUp(row) {    
        let index = row.Order__c - 1;
        if (index > 0) {
            if (! this.calculationsForAllCountriesMapCopy) {
                this.calculationsForAllCountriesMapCopy = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
            }

            let tempRow = this.calculationsForAllCountriesMap[this.country][index - 1];
            this.calculationsForAllCountriesMap[this.country][index - 1] = this.calculationsForAllCountriesMap[this.country][index];
            this.calculationsForAllCountriesMap[this.country][index] = tempRow;
            this.calculationsForAllCountriesMap = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
        }
    }


    moveRowDown(row) {
        let index = row.Order__c - 1;
        if (index < this.calculationsForAllCountriesMap[this.country].length - 1) {
            if (! this.calculationsForAllCountriesMapCopy) {
                this.calculationsForAllCountriesMapCopy = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
            }

            let tempRow = this.calculationsForAllCountriesMap[this.country][index + 1];
            this.calculationsForAllCountriesMap[this.country][index + 1] = this.calculationsForAllCountriesMap[this.country][index];
            this.calculationsForAllCountriesMap[this.country][index] = tempRow;
            this.calculationsForAllCountriesMap = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
        }
    }


    newCalculation(event) {
        if (! this.calculationsForAllCountriesMapCopy) {
            this.calculationsForAllCountriesMapCopy = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
        }

        if (this.country !== event.detail.Country__c) {
            this.country = event.detail.Country__c;
            event.detail.Order__c = this.calculationsForAllCountriesMap[this.country].length + 1;
        }

        this.calculationsForAllCountriesMap[this.country].push(event.detail);
        this.calculationsForAllCountriesMap = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
    }


    editCalculation(event) {
        let index = event.detail.Order__c - 1;

        if (! this.calculationsForAllCountriesMapCopy) {
            this.calculationsForAllCountriesMapCopy = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
        }
       
        this.calculationsForAllCountriesMap[this.country][index] = event.detail;
        this.calculationsForAllCountriesMap = JSON.parse(JSON.stringify(this.calculationsForAllCountriesMap));
    }


    handleAddNewClick() {
        const modal = this.template.querySelector("c-add-credit-factory-calculation-modal");
        if (modal) {
            modal.setCalculation({
                'Order__c': this.calculationsForAllCountriesMap[this.country].length + 1,
                'Country__c': this.country,
                isNew: true
            });
            modal.showModal();
        }
    }


    async handleSaveClick() {
        this.loading = true;
        await upsertCalculations({
            calculationsMap: this.calculationsForAllCountriesMap
        })
        .catch(error => {
            this.showToast('error', 'Error', TOAST_ERROR_MESSAGE);
            this.error = error;
        });

        if (this.calculationsIdToDelete.length) {
            await deleteCalculations({
                calculationsIdSet: this.calculationsIdToDelete
            })
            .catch(error => {
                this.showToast('error', 'Error', TOAST_ERROR_MESSAGE);
                this.error = error;
            });
        }

        if (! this.error) {
            this.init();
            this.calculationsForAllCountriesMapCopy = undefined;
            this.calculationsIdToDelete = [];
            this.showToast('success', 'Success', TOAST_SUCCESS_MESSAGE);
            this.loading = false;
        }
    }


    handleCancelClick() {
        this.calculationsForAllCountriesMap = this.calculationsForAllCountriesMapCopy;
        this.calculationsForAllCountriesMapCopy = undefined;
        this.calculationsIdToDelete = [];
    }


    showToast(type, title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(evt);
    }
}