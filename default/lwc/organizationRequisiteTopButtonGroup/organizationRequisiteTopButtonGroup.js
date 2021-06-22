import {api, LightningElement, track} from "lwc";
import { dispatchCustomEvent } from "c/eventUtils";
import { LABELS } from "c/textUtils";

export default class OrganizationRequisiteTopButtonGroup extends LightningElement {

    labels = LABELS;

    @api
    get disabled () {
        return this.isDisabled;
    }
    set disabled (value) {
        this.isDisabled = value;
    }

    @track isDisabled;

    handleStartDeduplicationClick(){
        dispatchCustomEvent(this, "startdeduplication");
    }

    handleStartSaving(){
        dispatchCustomEvent(this, "startsaving");
    }

    handleOpenModal(){
        dispatchCustomEvent(this, "openmodal");
    }

    handleExportXLS() {
        dispatchCustomEvent(this, "exportxls");
    }
}