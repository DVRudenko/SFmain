import { LightningElement, api, track } from "lwc";
import confirmCall from "@salesforce/apex/CreditFactoryCtrl.confirmCall";

export default class CreditFactoryReportCall extends LightningElement {
    @api opportunityId;
    @api mapData;
    @track isButtonDisabled = false;
    @track modalOpened;
    @track inputItem = {};
    @track loading;
    
    @api setIsDisabled(value) {
        this.isButtonDisabled = value;
    }
    
    handleChooseCall() {
        this.modalOpened = true;
    }
    
    async handleUpdateClick() {
        this.loading = true;
        this.dispatchEvent(new CustomEvent("disablebuttons", {
            bubbles: true
        }));
        
        const data = {
            dataMap: this.mapData,
            callId: this.inputItem.value,
            
        };
        
        const responseMessage = await confirmCall(data)
        .catch(error => {
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: error.body.message,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        });
        
        if (responseMessage) {
            this.dispatchEvent(new CustomEvent("doscoring", {
                detail: {
                    text: responseMessage,
                    success: true
                },
                bubbles: true
            }));
        }
    }
    
    hideModalHandler() {
        this.modalOpened = false;
    }
    
    selectModalHandler(event) {
        this.inputItem = event.detail;
        this.modalOpened = false;
    }
}