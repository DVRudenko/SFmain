import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import unlockRecord from '@salesforce/apex/UnlockRecordButtonController.unlockRecord';
import isRecordLocked from '@salesforce/apex/UnlockRecordButtonController.isButtonVisible';


export default class UnlockRecordButton extends LightningElement {
    @api recordId;
    @api recordLocked;

    handleClick(event) {
        unlockRecord({
            recordId: this.recordId
        }).then( result => {
            this.showToast('Success', 'Record is unlocked', 'success')
            isRecordLocked({
                recordId: this.recordId
            }).then(result => {
                this.recordLocked = result;
            });
        }).catch(result => {
            this.showToast('Error!', result, 'error');
        });
    }

    connectedCallback() {
        isRecordLocked({
            recordId: this.recordId
        }).then(result => {
            this.recordLocked = result;
        });
    }

    showToast(title, messsage, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: messsage,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}