import { LightningElement, api, track, wire } from "lwc";
import { PATTERN, LABELS } from "c/textUtils";
import { dispatchCustomEvent } from "c/eventUtils";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import CREDIT_FACTORY_REPORT_CREDIT_FIELD from "@salesforce/schema/Credit_Factory_Report__c.RU_scoring_type__c";
import { parseComponent } from "c/excelExport";

export default class CreditConditions extends LightningElement {
  @api credit;
  @api creditFactoryReportRecordTypeId;
  @api disabled;
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }

  @track creditDecisions;
  pattern = PATTERN;
  labels = LABELS;

  @wire(getPicklistValues, {
    recordTypeId: "$creditFactoryReportRecordTypeId",
    fieldApiName: CREDIT_FACTORY_REPORT_CREDIT_FIELD
  })
  setCredit(result) {
    if (result.data != null) {
      let data = JSON.parse(JSON.stringify(result.data.values));
      data[0].label = this.credit.creditDecision;
      data[0].value = this.credit.creditDecision;
      this.creditDecisions = data;
    }
  }

  handleChange(event) {
    this.dispatchCreditChangeEvent(event.target.name, event.target.value);
  }

  handleCheckCompanyClick() {
    dispatchCustomEvent(this, "creditconditionscheckcompany");
  }

  dispatchCreditChangeEvent(field, value) {
    dispatchCustomEvent(this, "decisionchange", {
      detail: {
        field: field,
        value: value
      }
    });
  }

  handleStartRMDApproval() {
    dispatchCustomEvent(this, "startapprovalprocess");
  }
}
