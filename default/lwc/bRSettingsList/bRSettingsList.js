import { LightningElement, wire, track } from "lwc";
import { BR_LABELS, handleSuccess, handleError } from "c/bRUtils";
import { refreshApex } from "@salesforce/apex";
import { deleteRecord } from "lightning/uiRecordApi";
import getAllBRSettings from "@salesforce/apex/BRSettingsController.getAllBRSettings";

export default class BRSettingsList extends LightningElement {
  labels = BR_LABELS;
  @track bRSettingsList = [];
  isModalOpen = false;
  showSettingPage = false;
  isHiddenBRSettingList = false;
  recordId;

  @track bRSettingsData = {
    Id: "",
    Is_active__c: false,
    Name: "",
    SObject__c: "",
    SObject_status__c: ""
  };

  @wire(getAllBRSettings) bRSettings(result) {
    if (result.data) {
      this.bRSettingsList = result;
    } else if (result.err) {
      handleError('',  err.body.message);
    }
  }

  handleOpenModal(event) {
    this.isModalOpen = true;
    this.recordId = event.target.value;
  }

  handleCloseModal() {
    this.isModalOpen = false;
  }

  handleDelete() {
    deleteRecord(this.recordId)
      .then(() => {
        refreshApex(this.bRSettingsList);
        handleSuccess(this.labels.TOST_DELETE_MESSAGE, this.labels.TOST_SUCCESS_MESSAGE);
      })
      .catch(error => handleError(this.labels.SYSTEM_EXCEPTION, error.body.message));
  }

  handleAddNewBRSetting() {
    this.isHiddenBRSettingList = true;
    this.showSettingPage = true;
    this.bRSettingsData = this.getEmptyBRSettingsData();
  }

  handleViewBRSetting(event) {
    const singleBRSetting = this.bRSettingsList.data.filter(item => item.Id == event.target.value);
    if (singleBRSetting) {
      this.bRSettingsData = singleBRSetting[0];
      this.isHiddenBRSettingList = true;
      this.showSettingPage = true;
    }
  }

  handleBackBtn() {
    refreshApex(this.bRSettingsList);
    this.isHiddenBRSettingList = false;
    this.showSettingPage = false;
  }

  getEmptyBRSettingsData() {
    return {
      Id: "",
      Is_active__c: false,
      Name: "",
      SObject__c: "",
      SObject_status__c: ""
    };
  }
}