import { LightningElement, api, wire, track } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import OPPORTUNITY_ELECTYRONIC_DOCUMENT_MENAGEMENT_FIELD from "@salesforce/schema/Opportunity.PPR_Electronic_document_management__c";
import { dispatchCustomEvent } from "c/eventUtils";
import { LABELS } from "c/textUtils";
import { parseComponent } from "c/excelExport";

export default class ElectronicDocumentData extends LightningElement {
  @api opportunityRecordTypeId;
  @api electronicDocumentData;
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }

  @track electronicDocumentOptions;
  labels = LABELS;

  @wire(getPicklistValues, {
    recordTypeId: "$opportunityRecordTypeId",
    fieldApiName: OPPORTUNITY_ELECTYRONIC_DOCUMENT_MENAGEMENT_FIELD
  })
  setElectronicDocumentData(result) {
    if (result.data != null) {
      let data = JSON.parse(JSON.stringify(result.data.values));
      this.electronicDocumentOptions = data;
    }
  }

  handleElectronicDocumentChange(event) {
    this.dispatchelEctronicDocumentChangeEvent("electronicDocument", event);
  }

  dispatchelEctronicDocumentChangeEvent(field, event) {
    dispatchCustomEvent(this, "electronicdocumentchange", {
      detail: {
        field: field,
        value: event.detail.value
      }
    });
  }
}
