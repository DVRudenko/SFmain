import { BR_LABELS } from "c/bRUtils";
import { api, LightningElement } from "lwc";

export default class ModalWindow extends LightningElement {
  @api isModalOpen = false;
  labels = BR_LABELS;

  closeModal() {
    this.isModalOpen = false;
    this.dispatchEvent(new CustomEvent("closemodal"));
  }

  deleteRecord() {
    this.closeModal();
    this.dispatchEvent(new CustomEvent("deleterecord"));
  }
}