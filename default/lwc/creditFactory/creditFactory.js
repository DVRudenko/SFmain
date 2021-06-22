import { LightningElement, track, api } from "lwc";


export default class CreditFactory extends LightningElement {
    @api opportunityId;
    @track dataMap;
    @track isSearch;
    @track isReport;
    @track selectedCompanyId;
    @track areReportsExist;
    @track toastMessage;

    connectedCallback() {
        this.isSearch = true;
    }
    
    reportHandler(event) {
        this.isSearch = false;
        this.isReport = true;
        this.areReportsExist = event.detail.areReportsExist;
        this.selectedCompanyId = event.detail.selectedCompanyId;
    }
    
    showToast(event) {
        if (this.timer) {
            clearTimeout(this.timer);
        }
        
        this.toastMessage = event.detail;  
        this.timer = setTimeout(() => {
            this.hideToast();
        }, 5000);
    }
    
    renderedCallback() {
        if (this.toastMessage) {
            this.template.querySelector('.slds-notify_toast').classList.remove(`slds-theme_success`, `slds-theme_error`);
            this.template.querySelector('.slds-notify_toast').classList.add(`slds-theme_${this.toastMessage.success ? 'success' : 'error'}`);
        }
    }
    
    hideToast() {
        this.toastMessage = null;
    }
    
    async doScoringHandler(event) {
        await this.template.querySelector("c-credit-factory-report").reDoScoring();
        
        this.showToast(event);
    }
}