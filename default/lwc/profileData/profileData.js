import { LightningElement, api } from "lwc";
import { PATTERN, LABELS, applyRussianPhoneMask } from "c/textUtils";
import { dispatchCustomEvent } from "c/eventUtils";
import { checkComponentValidityForSaving } from "c/organizationRequisiteValidator";
import { parseComponent } from "c/excelExport";

export default class ProfileData extends LightningElement {
  @api profile;
  @api
  checkValidityForSaving(canBeEmpty) {
    return checkComponentValidityForSaving(this.template, canBeEmpty);
  }
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }
  pattern = PATTERN;
  labels = LABELS;

  handleChange(event) {
    this.dispatchProfileChangeEvent(event.target.name, event.target.value);
  }

  handleProfilePhoneNumberChange(event) {
    const maskedPhone = applyRussianPhoneMask(event.target.value);
    this.dispatchProfileChangeEvent("phoneNumber", maskedPhone);
  }

  dispatchProfileChangeEvent(field, value) {
    dispatchCustomEvent(this, "profilechange", {
      detail: {
        field: field,
        value: value
      }
    });
  }
}
