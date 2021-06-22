import { LightningElement, api, wire, track } from "lwc";
import { dispatchCustomEvent } from "c/eventUtils";
import { LABELS } from "c/textUtils";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import OPPORTUNITY_TARIF_FIELD from "@salesforce/schema/Opportunity.Product_PPR__c";
import OPPORTUNITY_PROMOCODE_FIELD from "@salesforce/schema/Opportunity.Promo_campaign__c";
import OPPORTUNITY_ADDITIOANL_PROMOCODE_FIELD from "@salesforce/schema/Opportunity.Promo_Code1__c";
import { checkComponentValidityForSaving } from "c/organizationRequisiteValidator";
import { parseComponent } from "c/excelExport";

export default class TariffAndServices extends LightningElement {
  @api opportunityRecordTypeId;
  @api tariffAndServices;
  @api
  checkValidityForSaving() {
    return checkComponentValidityForSaving(this.template);
  }
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }

  @track tariffs;
  @track promocodes;
  @track additionalPromocodes;

  @wire(getPicklistValues, {
    recordTypeId: "$opportunityRecordTypeId",
    fieldApiName: OPPORTUNITY_TARIF_FIELD
  })
  setTariffs(result) {
    if (result.data != null) {
      this.tariffs = result.data.values;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$opportunityRecordTypeId",
    fieldApiName: OPPORTUNITY_PROMOCODE_FIELD
  })
  setPromocodes(result) {
    if (result.data != null) {
      this.promocodes = result.data.values;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$opportunityRecordTypeId",
    fieldApiName: OPPORTUNITY_ADDITIOANL_PROMOCODE_FIELD
  })
  setAdditionalPromocodes(result) {
    if (result.data != null) {
      this.additionalPromocodes = result.data.values;
    }
  }

  labels = LABELS;

  handelChange(event) {
    let apiName = event.target.name;
    let value =
      event.target.type == "toggle" ? event.target.checked : event.target.value;

    this.dispatchTariffAndServicesChange(apiName, value);
  }

  dispatchTariffAndServicesChange(apiName, value) {
    dispatchCustomEvent(this, "tariffandserviceschange", {
      detail: {
        field: apiName,
        value: value
      }
    });
  }
}
