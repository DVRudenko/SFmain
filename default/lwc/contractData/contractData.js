import { LightningElement, api, track, wire } from "lwc";
import { PATTERN, LABELS } from "c/textUtils";
import { dispatchCustomEvent } from "c/eventUtils";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import OPPORTUNITY_ORGANIZATION_FIELD from "@salesforce/schema/Opportunity.Our_organization__c";
import OPPORTUNITY_TYPE_OF_CONTRACT from "@salesforce/schema/Opportunity.CategoryContract__c";
import { checkComponentValidityForSaving } from "c/organizationRequisiteValidator";
import { parseComponent } from "c/excelExport";

export default class ContractData extends LightningElement {
  @api contractData;
  @api opportunityRecordTypeId;
  @api
  checkValidityForSaving(canBeEmpty) {
    return checkComponentValidityForSaving(this.template, canBeEmpty);
  }
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }

  pattern = PATTERN;
  labels = LABELS;

  @track organization;
  @track categoryOfСontract;

  @wire(getPicklistValues, {
    recordTypeId: "$opportunityRecordTypeId",
    fieldApiName: OPPORTUNITY_ORGANIZATION_FIELD
  })
  setOrganization(result) {
    if (result.data != null) {
      this.organization = result.data.values;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$opportunityRecordTypeId",
    fieldApiName: OPPORTUNITY_TYPE_OF_CONTRACT
  })
  setСategoryOfСontract(result) {
    if (result.data != null) {
      this.categoryOfСontract = result.data.values;
    }
  }

  handleChange(event) {
    let apiName = event.target.name;
    let value =
      event.target.type == "toggle" ? event.target.checked : event.target.value;

    this.dispatchСontractDataChange(apiName, value);
  }

  dispatchСontractDataChange(apiName, value) {
    dispatchCustomEvent(this, "contractdatachange", {
      detail: {
        field: apiName,
        value: value
      }
    });
  }
}
