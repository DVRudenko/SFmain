import { LightningElement, api, track } from "lwc";
import { PATTERN, LABELS } from "c/textUtils";
import { dispatchCustomEvent } from "c/eventUtils";
import { DADATA_METODS, requestDadata } from "c/dadataService";
import { checkComponentValidityForSaving } from "c/organizationRequisiteValidator";
import { parseComponent } from "c/excelExport";

export default class BankData extends LightningElement {
  @api bankData;
  @api
  checkValidityForSaving(canBeEmpty) {
    return checkComponentValidityForSaving(this.template, canBeEmpty);
  }
  @track bankList = [];

  @api get exportableFields() {
    return parseComponent(this, "ru");
  }
  pattern = PATTERN;
  labels = LABELS;
  showDadataSuggestions = false;

  get bankListEmpty() {
    return this.bankList.length == 0;
  }

  handleBankNameChange(event) {
    const inputValue = event.target.value;
    this.dispatchContactChangeEvent(event.target.name, inputValue);

    if (inputValue && inputValue.length > 0) {
      this.requestBankData(inputValue);
    }
  }

  handleСheckingAccountChange(event) {
    this.dispatchContactChangeEvent(event.target.name, event.target.value);
  }

  requestBankData(value) {
    requestDadata(DADATA_METODS.bank, value).then((result) => {
      this.bankList = result ? JSON.parse(result).suggestions : [];
      this.bankList.forEach((bank) => {
        if (bank.data.state.status != "ACTIVE") {
          bank["styleClass"] = "bank-list-item-disabled";
        }
      });
      this.showDadataSuggestions = true;
    });
  }

  handleOptionSelect(event) {
    const bankBic = event.currentTarget.dataset.id;
    for (const bank of this.bankList) {
      if (bank.data.bic == bankBic) {
        if (bank.data.state.status == "ACTIVE") {
          this.setBankData(
            bank.value,
            bank.data.bic,
            bank.data.correspondent_account
          );
          this.showDadataSuggestions = false;
        } else {
          event.preventDefault();
        }
        break;
      }
    }
  }

  handleListOut() {
    let resetBankData = true;
    if (
      this.bankList &&
      this.bankList.length > 0 &&
      this.bankData.bankName &&
      this.bankData.bankName.length > 0
    ) {
      for (const bank of this.bankList) {
        if (bank.value == this.bankData.bankName) {
          resetBankData = false;
          break;
        }
      }
    }

    if (resetBankData) {
      this.setBankData("", "", "");
    }

    this.checkFieldValiity("bankName");
    this.showDadataSuggestions = false;
  }

  setBankData(bankName, bankBic, corBankAccount) {
    this.dispatchContactChangeEvent("bankName", bankName);
    this.dispatchContactChangeEvent("bankBic", bankBic);
    this.dispatchContactChangeEvent("corBankAccount", corBankAccount);
  }

  checkFieldValiity(fieldName) {
    const inputComponents = this.template.querySelectorAll("lightning-input");
    for (const component of inputComponents) {
      if (component.name == fieldName) {
        const errorValue =
          this.bankData[fieldName].length > 0
            ? ""
            : this.labels.COMPLETE_THIS_FIELD;
        component.setCustomValidity(errorValue);
        component.reportValidity();
        break;
      }
    }
  }

  handleUnknownBankClick(event) {
    event.preventDefault();
  }

  dispatchContactChangeEvent(field, value) {
    dispatchCustomEvent(this, "bankdatachange", {
      detail: {
        field: field,
        value: value
      }
    });
  }
}
