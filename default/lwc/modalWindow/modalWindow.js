import {LABELS} from "c/textUtils";
import {api, LightningElement} from "lwc";

export default class ModalWindow extends LightningElement {
  @api isModalOpen = false;
  labels = LABELS;

  closeModal() {
    this.dispatchEvent(new CustomEvent('closemodal'));
  }

  createClient() {
    this.dispatchEvent(new CustomEvent('createclient'));
  }
}