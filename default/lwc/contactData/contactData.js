import { LightningElement, api } from "lwc";
import { PATTERN, LABELS, applyRussianPhoneMask } from "c/textUtils";
import { dispatchCustomEvent } from "c/eventUtils";
import { checkComponentValidityForSaving } from "c/organizationRequisiteValidator";
import { parseComponent } from "c/excelExport";

export default class ContactData extends LightningElement {
  @api contact;
  @api
  checkValidityForSaving(canBeEmpty) {
    let isValidPattern = checkComponentValidityForSaving(
      this.template,
      canBeEmpty
    );
    let isNotEmptyContactName = this.contact.fullName.trim() !== "";
    return isValidPattern && isNotEmptyContactName;
  }
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }

  pattern = PATTERN;
  labels = LABELS;

  handleContactPhoneNumberChange(event) {
    const maskedPhone = applyRussianPhoneMask(event.target.value);
    this.dispatchContactChangeEvent(event.target.name, maskedPhone);
  }

  handleChange(event) {
    this.dispatchContactChangeEvent(event.target.name, event.target.value);
  }

  dispatchContactChangeEvent(field, value) {
    dispatchCustomEvent(this, "contactchange", {
      detail: {
        field: field,
        value: value
      }
    });
  }
}
