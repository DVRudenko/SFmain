import { LightningElement, api, track, wire } from "lwc";
import { BR_LABELS, handleSuccess, handleError } from "c/bRUtils";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import BR_SETTING_OBJECT from "@salesforce/schema/BR_Setting__c";
import BR_SETTING_SOBJECT_FIELD from "@salesforce/schema/BR_Setting__c.SObject__c";
import BR_SETTING_SOBJECT_STATUS_FIELD from "@salesforce/schema/BR_Setting__c.SObject_status__c";
import saveSetting from "@salesforce/apex/BRSettingsController.saveSetting";

export default class BRSettingsPage extends LightningElement {
  labels = BR_LABELS;
  @api bRSettingsData;

  @track objectNames;
  @track resultStatus;
  isShowButtons = true;
  isDisabled = true;

  @wire(getObjectInfo, { objectApiName: BR_SETTING_OBJECT })
  objectInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: BR_SETTING_SOBJECT_FIELD
  })
  setSObjectPicklist(result) {
    if (result.data != null) {
      this.objectNames = result.data.values;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: BR_SETTING_SOBJECT_STATUS_FIELD
  })
  setSObjectStatusPicklist(result) {
    if (result.data != null) {
      this.resultStatus = result.data.values;
    }
  }

  handleBackBtn() {
    this.dispatchEvent(new CustomEvent("back"));
  }

  handleEditBtn() {
    this.isShowButtons = false;
    this.isDisabled = false;
  }

  handleCancelBtn() {
    this.isShowButtons = true;
    this.isDisabled = true;
  }

  handleSaveBtn() {
    let wrapBRData = this.mapBRSettingsData();
    this.bRSettingsData.Id == "" && delete wrapBRData.id;
    wrapBRData = JSON.stringify(wrapBRData);
    saveSetting({ settingData: wrapBRData })
      .then(() => handleSuccess("", this.labels.BR_SETTING_SAVE_SUCCESSFULLY))
      .catch(error => handleError('', error.body.message));
  }

  handleChange(event) {
    const CHECK_BOX_TOGGLE = 'toggle';
    let value = event.target.type == CHECK_BOX_TOGGLE ? event.target.checked : event.target.value;
    const bRData = JSON.parse(JSON.stringify(this.bRSettingsData));
    bRData[event.target.name] = value;
    this.bRSettingsData = bRData;
  }

  mapBRSettingsData() {
    return {
      id: this.bRSettingsData.Id,
      name: this.bRSettingsData.Name,
      isActive: this.bRSettingsData.Is_active__c,
      sObjectName: this.bRSettingsData.SObject__c,
      sObjectStatus: this.bRSettingsData.SObject_status__c
    };
  }
}