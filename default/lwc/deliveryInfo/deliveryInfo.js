import { LightningElement, api, track } from "lwc";
import { PATTERN, LABELS } from "c/textUtils";
import { dispatchCustomEvent } from "c/eventUtils";
import { DADATA_METODS, requestDadata } from "c/dadataService";
import { checkComponentValidityForSaving } from "c/organizationRequisiteValidator";
import { parseComponent } from "c/excelExport";

export default class DeliveryInfo extends LightningElement {
  @api counterparty;
  @api deliveryInfo;
  @api
  checkValidityForSaving() {
    return checkComponentValidityForSaving(this.template);
  }
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }
  @track shippingAdressSuggestions = [];
  showShippingAdress = false;
  @track searchvalue;
  @track textValidation;

  pattern = PATTERN;
  labels = LABELS;
  get isDisabledCopyButton() {
    return !(
      this.counterparty.isValidPosalAddress ||
      this.counterparty.postalAddress == ""
    );
  }

  fireListener(event, searchCmp) {
    window.addEventListener("click", (event) => {
      if (!searchCmp.contains(event.target)) {
        this.showShippingAdress = false;
      }
    });
  }

  async handelShippingAdressChange(event) {
    let searchChangeShippingAddress = this.template.querySelector(
      ".changeShippingAdress"
    );
    let searchShippingAddressCmp =
      this.template.querySelector(".shippinglAddress");
    let value = event.target.value;
    let apiName = event.target.name;
    this.dispatchDeliveryInfoChange(apiName, value);
    if (value && value.length > 0) {
      let dataShippingAdress = await requestDadata(
        DADATA_METODS.address,
        value
      );
      const responseShippingAdress = JSON.parse(dataShippingAdress);
      this.shippingAdressSuggestions = responseShippingAdress.suggestions;
    }
    if (this.shippingAdressSuggestions.length > 0 && value.length > 0) {
      searchChangeShippingAddress.setCustomValidity(
        LABELS.COMPLETE_ADDRESS_FIELD
      );
      searchChangeShippingAddress.reportValidity();
      this.showShippingAdress = true;
      this.fireListener(event, searchChangeShippingAddress);
    }
  }

  handelClickСhangeShippingAdress(event) {
    let searchChangeShippingAddress = this.template.querySelector(
      ".changeShippingAdress"
    );
    let searchShippingAddressCmp =
      this.template.querySelector(".shippinglAddress");

    let apiName = event.target.name;
    this.searchvalue = this.isAddressValid(
      this.shippingAdressSuggestions,
      event.target.textContent
    );
    this.dispatchDeliveryInfoChange(
      searchChangeShippingAddress.name,
      event.target.textContent
    );
    if (this.searchvalue) {
      searchChangeShippingAddress.setCustomValidity("");
      searchChangeShippingAddress.reportValidity();
    }
  }

  handelChange(event) {
    let apiName = event.target.name;
    let value = event.target.value;
    this.dispatchDeliveryInfoChange(apiName, value);
  }

  handleCopyAddressClick() {
    let inputComponents = this.template.querySelector(".changeShippingAdress");
    this.dispatchDeliveryInfoChange(
      "shippingAddress",
      this.counterparty.postalAddress
    );
    window.setTimeout(() => {
      inputComponents.setCustomValidity("");
      inputComponents.reportValidity();
    }, 10);
  }

  dispatchDeliveryInfoChange(apiName, value) {
    dispatchCustomEvent(this, "deliveryinfochange", {
      detail: {
        field: apiName,
        value: value
      }
    });
  }

  isAddressValid(suggestions, address) {
    for (let suggestion of suggestions) {
      if (suggestion.unrestricted_value == address) {
        if (suggestion.data != null) {
          let data = suggestion.data;
          if (data.house != null && data.postal_code != null) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
