import { LightningElement, api, track, wire } from "lwc";
import { PATTERN, LABELS } from "c/textUtils";
import { dispatchCustomEvent } from "c/eventUtils";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import OPPORTUNITY_SOURCE_OF_LEAD_FIELD from "@salesforce/schema/Opportunity.Source_of_Lead_o__c";
import { DADATA_METODS, requestDadata } from "c/dadataService";
import { checkComponentValidityForSaving } from "c/organizationRequisiteValidator";
import { mapDadataSelectedValueIntoAddress } from "c/mappingFromObjectToDtoService";
import { parseComponent } from "c/excelExport";

export default class CounterpartyData extends LightningElement {
  @api opportunityRecordTypeId;
  @api counterparty;
  @api
  checkValidityForSaving(canBeEmpty) {
    let isValidPattern = checkComponentValidityForSaving(
      this.template,
      canBeEmpty
    );
    let isValidAccName = this.counterparty.name.trimStart() !== "";
    let isValidContactName =
      this.counterparty.leaderFullName.trimStart() !== "";
    return isValidPattern && isValidAccName && isValidContactName;
  }
  @api get exportableFields() {
    return parseComponent(this, "ru");
  }

  @track searchChannelOptions;
  @track legalAdressSuggestions = [];
  @track postalAdressSuggestions = [];
  @track isButtonDisabled = true;
  @track isLegalAssressValid = false;
  showLegalAdress = false;
  showPostalAdress = false;
  @track searchvalue;
  @track textValidation;
  pattern = PATTERN;
  labels = LABELS;

  @wire(getPicklistValues, {
    recordTypeId: "$opportunityRecordTypeId",
    fieldApiName: OPPORTUNITY_SOURCE_OF_LEAD_FIELD
  })
  setSearchChannelOptions(result) {
    if (result.data != null) {
      this.searchChannelOptions = result.data.values;
    }
  }

  fireListener(event, searchCmp) {
    window.addEventListener("click", (event) => {
      if (!searchCmp.contains(event.target)) {
        this.showLegalAdress = false;
        this.showPostalAdress = false;
      }
    });
  }

  async handelLegalAdressChange(event) {
    let searchChangeLegalAddress =
      this.template.querySelector(".changeLegalAdress");
    let searchLegalAddressCmp = this.template.querySelector(".legalAddress");
    let value = event.target.value;
    let apiName = event.target.name;
    this.dispatchCounterpartyChangeEvent(apiName, value);
    if (this.textValidation == event.target.value.length) {
      this.isButtonDisabled = false;
      this.isLegalAssressValid = true;
    } else {
      this.isButtonDisabled = true;
    }
    if (value && value.length > 0) {
      let dataLegalAdress = await requestDadata(DADATA_METODS.address, value);
      const responseLegalAdress = JSON.parse(dataLegalAdress);
      this.legalAdressSuggestions = responseLegalAdress.suggestions;
    }
    if (this.legalAdressSuggestions.length > 0 && value.length > 0) {
      searchChangeLegalAddress.setCustomValidity(LABELS.COMPLETE_ADDRESS_FIELD);
      searchChangeLegalAddress.reportValidity();
      this.isLegalAssressValid = false;
      this.showLegalAdress = true;
      this.fireListener(event, searchChangeLegalAddress);
    }
    if (this.counterparty.legalAddress.length == 0) {
      let emptyAddress = mapDadataSelectedValueIntoAddress();
      this.dispatchCounterpartyChangeEvent(
        "legalAddressAsObject",
        emptyAddress
      );
    }
  }

  handelClickСhangeLegalAdress(event) {
    let searchChangeLegalAddress =
      this.template.querySelector(".changeLegalAdress");
    let searchLegalAddressCmp = this.template.querySelector(".legalAddress");
    let apiName = event.target.name;
    this.setAdressObject(
      this.legalAdressSuggestions,
      event.target.textContent,
      "legalAddressAsObject"
    );
    this.searchvalue = this.isAddressValid(
      this.legalAdressSuggestions,
      event.target.textContent
    );
    this.dispatchCounterpartyChangeEvent(
      searchChangeLegalAddress.name,
      event.target.textContent
    );
    if (this.searchvalue) {
      searchChangeLegalAddress.setCustomValidity("");
      searchChangeLegalAddress.reportValidity();
      this.isButtonDisabled = false;
      this.isLegalAssressValid = true;
    } else {
      this.isButtonDisabled = true;
    }
  }

  async handelPostalAdressChange(event) {
    let searchChangePostalAddress = this.template.querySelector(
      ".changePostalAdress"
    );
    let searchPostalAddressCmp = this.template.querySelector(".postalAddress");
    let value = event.target.value;
    let apiName = event.target.name;
    this.dispatchCounterpartyChangeEvent(apiName, value);
    if (value && value.length > 0) {
      let dataPostalAdress = await requestDadata(DADATA_METODS.address, value);
      const responsePostalAdress = JSON.parse(dataPostalAdress);
      this.postalAdressSuggestions = responsePostalAdress.suggestions;
    }
    if (this.postalAdressSuggestions.length > 0 && value.length > 0) {
      if (this.textValidation && this.isLegalAssressValid) {
        this.isButtonDisabled = false;
      }
      this.showPostalAdress = true;
      this.fireListener(event, searchChangePostalAddress);
      searchChangePostalAddress.setCustomValidity(
        LABELS.COMPLETE_ADDRESS_FIELD
      );
      searchChangePostalAddress.reportValidity();
      if (this.counterparty.postalAddress.length == 0) {
        let emptyAddress = mapDadataSelectedValueIntoAddress();
        this.dispatchCounterpartyChangeEvent(
          "postalAddressAsObject",
          emptyAddress
        );
      }
    }
    let postalAddressValidity = searchChangePostalAddress.checkValidity();
    if (postalAddressValidity != this.counterparty.isValidPosalAddress) {
      this.dispatchCounterpartyChangeEvent(
        "isValidPosalAddress",
        postalAddressValidity
      );
    }
    if (this.counterparty.postalAddress.length == 0) {
      let emptyAddress = mapDadataSelectedValueIntoAddress();
      this.dispatchCounterpartyChangeEvent(
        "postalAddressAsObject",
        emptyAddress
      );
    }
  }

  handelClickСhangePostalAdress(event) {
    let searchChangePostalAddress = this.template.querySelector(
      ".changePostalAdress"
    );
    let searchPostalAddressCmp = this.template.querySelector(".postalAddress");
    let apiName = event.target.name;

    this.setAdressObject(
      this.postalAdressSuggestions,
      event.target.textContent,
      "postalAddressAsObject"
    );
    this.searchvalue = this.isAddressValid(
      this.postalAdressSuggestions,
      event.target.textContent
    );
    this.dispatchCounterpartyChangeEvent(
      searchChangePostalAddress.name,
      event.target.textContent
    );
    if (this.searchvalue) {
      searchChangePostalAddress.setCustomValidity("");
      searchChangePostalAddress.reportValidity();
    }
    let postalAddressValidity = searchChangePostalAddress.checkValidity();
    if (postalAddressValidity != this.counterparty.isValidPosalAddress) {
      this.dispatchCounterpartyChangeEvent(
        "isValidPosalAddress",
        postalAddressValidity
      );
    }
  }

  setAdressObject(suggestions, address, adressTypeField) {
    let adressForSet;
    if (suggestions != null && suggestions.length > 0) {
      for (let suggestion of suggestions) {
        if (suggestion.unrestricted_value == address) {
          if (suggestion.data != null) {
            adressForSet = mapDadataSelectedValueIntoAddress(suggestion);
            this.dispatchCounterpartyChangeEvent(adressTypeField, adressForSet);
            break;
          }
        }
      }
    }
  }

  handelChange(event) {
    let apiName = event.target.name;
    let value = event.target.value;
    this.dispatchCounterpartyChangeEvent(apiName, value);
  }

  handleLitersPredictionChange(event) {
    let value = event.target.value;
    var turnoverPattern = new RegExp(this.pattern.turnover);
    if (value.length > 0 && !turnoverPattern.test(value)) {
      event.target.value = this.counterparty[event.target.name];
    }
    this.handelChange(event);
  }

  handleCopyAddressClick() {
    this.isButtonDisabled = true;
    let inputComponents = this.template.querySelector(".changePostalAdress");
    dispatchCustomEvent(this, "counterpartycopyaddress");
    window.setTimeout(() => {
      inputComponents.setCustomValidity("");
      inputComponents.reportValidity();
    }, 10);
  }

  handleUseSPARKDataChanged(event) {
    let disable = event.target.checked;
    this.disableSPARKFields(disable);
  }

  dispatchCounterpartyChangeEvent(field, value) {
    dispatchCustomEvent(this, "counterpartychange", {
      detail: {
        field: field,
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
            this.textValidation = address.length;
            return true;
          }
        }
      }
    }
    return false;
  }

  @api disableSPARKFields(disable) {
    this.isButtonDisabled = false;
    this.isLegalAssressValid = true;
    dispatchCustomEvent(this, "counterpartyusesparkdata", { detail: disable });
    let validNames = [
      "name",
      "iNN",
      "kPP",
      "oGRN",
      "okVED",
      "oKPO",
      "leaderFullName",
      "leaderPosition"
    ];

    this.template.querySelectorAll("lightning-input").forEach((element) => {
      if (validNames.includes(element.name)) {
        element.disabled = disable;
        element.reportValidity();
      }
    });

    this.template.querySelectorAll("lightning-textarea").forEach((element) => {
      if (
        element.name == "legalAddress" &&
        this.counterparty.iNN.length == 10
      ) {
        element.disabled = disable;
        element.reportValidity();
      }
    });
  }
}
