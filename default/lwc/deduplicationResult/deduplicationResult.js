import { LightningElement, api, track } from "lwc";
import { LABELS } from "c/textUtils";
import { dispatchCustomEvent } from "c/eventUtils";
import { parseComponent } from "c/excelExport";

export default class DeduplicationResult extends LightningElement {
  @api disabled;

  labels = LABELS;

  @api
  get deduplicationResult() {
    return this.deduplicationResult;
  }
  set deduplicationResult(value) {
    this.deduplicationResult = value;
  }
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }

  @track deduplicationResult;

  handleStartApprovalProcessClick() {
    dispatchCustomEvent(this, "startapprovalprocess");
  }
}
