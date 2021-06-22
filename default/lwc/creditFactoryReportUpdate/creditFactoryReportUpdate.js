import { LightningElement, api, track } from "lwc";
import doUpdate from "@salesforce/apex/CreditFactoryCtrl.doUpdate";

export default class CreditFactoryReportName extends LightningElement {
    @api fields;
    @api mapData;
    @track isButtonDisabled = false;
    @track value = '';
    @track loading;
    
    @api setIsDisabled(value) {
        this.isButtonDisabled = value;
    }
    
    connectedCallback() {
        this.value = this.fields.creditSystemData.items[0].value;
    }
    
    get options() {
        return this.fields.creditSystemData.items;
    }
    
    get label() {
        return this.fields.creditSystemData.header;
    }
    
    handleChange(event) {
        this.value = event.detail.value;
    }
    
    async handleUpdateClick() {
        this.loading = true;
        this.dispatchEvent(new CustomEvent("disablebuttons", {
            bubbles: true
        }));
        
        const data = {
            dataMap: this.mapData,
            type: this.value
        };
        
        
        const responseMessage = await doUpdate(data)
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
}