import { LightningElement, wire, api, track } from "lwc";
import getCallTasksList from "@salesforce/apex/CreditFactoryCtrl.getCallTasksList";

const columns = [
    { label: "Subject", fieldName: "Subject" },
    { label: "Due Date", fieldName: "ActivityDate" },
    { label: "Status", fieldName: "Status" },
    { label: "Priority", fieldName: "Priority" },
    { label: "Last Modified Date", fieldName: "LastModifiedDate" }
];

export default class CreditFactoryReportCallModal extends LightningElement {
    @api opportunityId;
    @track item;
    columns = columns;
    @track isSelectDisabled;
    @wire(getCallTasksList, {opportunityId: "$opportunityId"})
    callTasks;
    
    connectedCallback() {
        this.isSelectDisabled = true;
    }
    
    handleHideModal() {
        this.dispatchEvent(new CustomEvent("modalhide"));
    }
    
    handleSelectItem() {
        this.dispatchEvent(new CustomEvent("modalselect", {
            detail: this.item
        }));
    }
    
    getSelectedCall(event) {
        this.isSelectDisabled = false;
        const selectedRows = event.detail.selectedRows; 
        this.item = {
            label: selectedRows[0].Subject,
            value: selectedRows[0].Id
        };
    }
}