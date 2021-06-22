import { LightningElement, api, track, wire } from "lwc";
import { PATTERN, LABELS } from "c/textUtils";
import getSoleProprietorSparkData from "@salesforce/apex/CFServiceLightning.getSoleProprietorSparkData";
import getCompanySparkData from "@salesforce/apex/CFServiceLightning.getCompanySparkData";
import getBlackListData from "@salesforce/apex/CFServiceLightning.getBlackListData";
import getPreScoringData from "@salesforce/apex/CFServiceLightning.getPreScoringData";
import getSparkArbitrationSummaryList from "@salesforce/apex/CFServiceLightning.getSparkArbitrationSummaryList";
import getSparkExecutionProceedings from "@salesforce/apex/CFServiceLightning.getSparkExecutionProceedings";
import getSparkFinancialReports from "@salesforce/apex/CFServiceLightning.getSparkFinancialReports";
import getSparkRiskReport from "@salesforce/apex/CFServiceLightning.getSparkRiskReport";
import getDeduplicationStatusName from "@salesforce/apex/DeduplicationServiceLightning.getDeduplicationStatusName";
import createDirectumContract from "@salesforce/apex/EESBControllerLightning.createDirectumContract";
import isRecordLockedByApprovalProces from "@salesforce/apex/ApprovalService.isRecordLockedByApprovalProces";
import getApprovalProcesses from "@salesforce/apex/ApprovalService.getApprovalProcesses";
import getOrganizationRequisiteDataByOppId from "@salesforce/apex/OrganizationRequisiteDataService.getOrganizationRequisiteDataByOppId";
import getScoringDecision from "@salesforce/apex/OrganizationRequisiteDataService.getScoringDecision";
import checkForApproval from "@salesforce/apex/ApprovalProcessServiceLightning.checkForApproval";
import getCustomSettings from "@salesforce/apex/ApprovalProcessServiceLightning.getCustomSettings";
import getRussianCreditCheckRecordTypeId from "@salesforce/apex/OrganizationRequisiteDataService.getRussianCreditCheckRecordTypeId";
import { getInavlidForSavingSections } from "c/organizationRequisiteValidator";
import { getFormattedDate } from "c/dateUtils";
import { exportData } from "c/excelExport";
import {
  mapSparkAddressIntoAddress,
  mapPrimaryContactBdData,
  mapAccountBdData,
  mapOpportunityBdData,
  mapCreditFactoryReportsBdData,
  mapFieldsForDirectum
} from "c/mappingFromObjectToDtoService";

import { mapDataForSaving } from "c/mappingFromDtoToOjbectService";

import {
  updateSfData,
  getSfPrimaryContact,
  getSfLeaderContacts,
  updateSparkDataFields,
  upsertCreditFactoryFields
} from "c/organizationRequisiteService";

import {
  startDeduplication,
  approvalProcessNameForStart,
  isDisabledApprovalButton,
  deduplicationResult
} from "c/deduplicationService";

export default class ApplicationWithOrganizationRequisite extends LightningElement {
  @api opportunityId;
  @api recordTypeId;
  @api creditFactoryReportRecordTypeId;
  isModalOpen = false;
  isLoadingContent = false;
  isSendToDirectum = false;
  pattern = PATTERN;
  labels = LABELS;
  deduplicationStatus;
  scoringDecision;
  approvalProcessNameToStart;
  isDisabledApprovalProcess = true;
  isDisabledRMDApprovalProcess = true;
  russianCreditCheckRecordTypeId;
  preScoringOverdraft;

  childCompToLabelMap = new Map([
    ["c-counterparty-data", this.labels.COUNTERPARTY_DATA],
    ["c-bank-data", this.labels.BANK_INFORMATION],
    ["c-contact-data", this.labels.CONTACT_DATA],
    ["c-profile-data", this.labels.PERSONAL_ACCOUNT],
    ["c-contract-data", this.labels.CONTRACT_INFORMATION],
    ["c-delivery-info", this.labels.DELIVERY_INFO],
    ["c-tariff-and-services", this.labels.TARIFF_AND_SERVICES]
  ]);

  @track contact = {
    phoneNumber: "",
    email: "",
    fullName: "",
    position: ""
  };
  @track counterparty = {
    name: "",
    iNN: "",
    kPP: "",
    oGRN: "",
    okVED: "",
    oKPO: "",
    legalAddress: "",
    postalAddress: "",
    leaderFullName: "",
    leaderPosition: "",
    useSPARKData: false,
    litersPrediction: "",
    carCount: "",
    truckCount: "",
    partnerProgram: "",
    searchChannel: "",
    isValidPosalAddress: true,
    legalAddressAsObject: {},
    postalAddressAsObject: {}
  };
  @track tariffAndServices = {
    selectedTariff: "",
    cardsAmount: "",
    cardsAmountTK: "",
    cardsAmountBK: "",
    selectedPromocode: "",
    selectedAdditionalPromocode: "",
    virtualCardsSelected: false,
    personalConsultantSelected: false,
    documentsExpressDeliverySelected: false
  };
  @track deliveryInfo = {
    shippingAddress: "",
    originalDocumentCourierInfo: "",
    cardsDeliveryCourierInfo: ""
  };
  @track profile = {
    email: "",
    codeWord: "",
    phoneNumber: "",
    unificationLKGK: ""
  };
  @track credit = {
    blackListDecision: "",
    preScoringDecision: "",
    preScoringExpirationDate: "",
    creditDecision: ""
  };
  sparkResponseJSON = null;
  sparkResponseJSONFull = null;
  @track sparkData = {
    name: "",
    iNN: "",
    kPP: "",
    oGRN: "",
    okVED: "",
    oKPO: "",
    legalAddress: "",
    legalAddressAsObject: {},
    leaderFullName: "",
    leaderPosition: ""
  };
  blackListResponseJSON = null;
  preScoringResponseJSON = null;
  @track electronicDocumentData = {
    electronicDocument: ""
  };
  @track contractData = {
    amountPayment: "",
    organization: "",
    categoryOfСontract: "",
    сontractSubject: "",
    contractNote: "",
    standardСontractSelected: false,
    contractAmount: "",
    withAutoRolloverSelected: false
  };
  @track bankData = {
    bankName: "",
    bankBic: "",
    checkingAccount: "",
    corBankAccount: ""
  };
  @track deduplicationResult;
  @track isDisabled = true;
  @track sfAccount;
  @track sfOpportunity;
  @track sfPrimaryContact;
  @track sfLeaderContacts = [];
  @track sfCreditFactoryReports;
  requestBody = {};
  customSettingNames;

  @wire(getDeduplicationStatusName) statusName({ err, data }) {
    if (data) {
      this.deduplicationStatus = data;
    } else if (err) {
      this.handleError(err);
    }
  }

  @wire(getScoringDecision) scoringDecision({ err, data }) {
    if (data) {
      this.scoringDecision = data;
    } else if (err) {
      this.handleError(err);
    }
  }

  @wire(getOrganizationRequisiteDataByOppId, {
    opportunityId: "$opportunityId"
  })
  wiredData({ err, data }) {
    this.isLoadingContent = true;
    if (data) {
      this.sfAccount = data.account[0];
      this.sfOpportunity = data.opportunity[0];
      this.sfCreditFactoryReports = data.creditFactoryReports[0]
        ? data.creditFactoryReports[0]
        : null;
      if (data.oppContactRoles.length != 0) {
        this.sfPrimaryContact = getSfPrimaryContact(data.oppContactRoles);
        this.sfLeaderContacts = getSfLeaderContacts(data.oppContactRoles);
      } else {
        this.sfPrimaryContact = null;
      }
      if (this.sfAccount != null) {
        mapAccountBdData(
          this.sfAccount,
          this.counterparty,
          this.bankData,
          this.deliveryInfo,
          this.profile,
          this.credit
        );
      }
      if (this.sfOpportunity != null) {
        mapOpportunityBdData(
          this.sfOpportunity,
          this.counterparty,
          this.tariffAndServices,
          this.electronicDocumentData,
          this.contractData
        );
      }
      if (this.sfCreditFactoryReports != null) {
        mapCreditFactoryReportsBdData(
          this.sfCreditFactoryReports,
          this.credit,
          this
        );
      }
      if (this.sfPrimaryContact != null) {
        mapPrimaryContactBdData(
          this.sfPrimaryContact,
          this.contact,
          this.profile
        );
      }
      this.isLoadingContent = false;
    } else if (err) {
      this.handleError(err);
      this.isLoadingContent = false;
    }
  }

  @wire(getCustomSettings) customSetting({ err, data }) {
    if (data) {
      this.customSettingNames = data;
    } else if (err) {
      this.handleError(err);
    }
  }

  @wire(getRussianCreditCheckRecordTypeId) getRussianCreditCheckRecordTypeId({
    err,
    data
  }) {
    if (data) {
      this.russianCreditCheckRecordTypeId = data;
    } else if (err) {
      this.handleError(err);
    }
  }

  applySparkDataToCounterparty() {
    if (this.counterparty.useSPARKData) {
      for (let field in this.sparkData) {
        this.counterparty[field] = this.sparkData[field];
      }
    }
  }

  handleUseSparkData(event) {
    this.counterparty.useSPARKData = event.detail;
    this.applySparkDataToCounterparty();
  }

  handleContactDataChange(event) {
    this.contact[event.detail.field] = event.detail.value;
    this.handleCheckDeduplicationData(
      this.contact.email,
      this.counterparty.iNN,
      this.contact.phoneNumber
    );
  }

  handleCounterpartyDataChange(event) {
    this.counterparty[event.detail.field] = event.detail.value;
    this.handleCheckDeduplicationData(
      this.contact.email,
      this.counterparty.iNN,
      this.contact.phoneNumber
    );
  }

  handleProfileDataChange(event) {
    this.profile[event.detail.field] = event.detail.value;
  }

  handleCreditDataChange(event) {
    this.credit[event.detail.field] = event.detail.value;
  }

  handleCheckCompany() {
    if (new RegExp(this.pattern.iNN).test(this.counterparty.iNN) == false) {
      alert(
        this.labels.INVALID_INN_ERROR.replace("{inn}", this.counterparty.iNN)
      );
    } else {
      switch (this.counterparty.iNN.length) {
        case 10: {
          if (
            new RegExp(this.pattern.turnover).test(
              this.counterparty.litersPrediction
            ) == false
          ) {
            alert(this.labels.INVALID_TURNOVER_ERROR);
          } else {
            this.processLegalEntityCheck();
          }
          break;
        }
        case 12: {
          this.processSoleProprietorCheck();
          break;
        }
        default:
          break;
      }
    }
  }

  handleElectronicDocumentDataChange(event) {
    this.electronicDocumentData[event.detail.field] = event.detail.value;
  }

  handleCopyAddress(event) {
    this.counterparty.postalAddress = this.counterparty.legalAddress;
    this.counterparty.postalAddressAsObject =
      this.counterparty.legalAddressAsObject;
  }

  handleTariffAndServicesChange(event) {
    this.tariffAndServices[event.detail.field] = event.detail.value;
  }

  handleDeliveryInfoChange(event) {
    this.deliveryInfo[event.detail.field] = event.detail.value;
  }

  handleContractDataChange(event) {
    this.contractData[event.detail.field] = event.detail.value;
  }

  processLegalEntityCheck() {
    this.isLoadingContent = true;
    getCompanySparkData({ inn: this.counterparty.iNN })
      .then((result) => {
        if (result != null) {
          this.sparkResponseJSON = result;
          let companySparkData = JSON.parse(result);
          this.processSparkData(companySparkData);
          this.applySparkDataToCounterparty();
          this.template
            .querySelector("c-counterparty-data")
            .disableSPARKFields(true);
          getBlackListData({
            inn: companySparkData.inn,
            sparkID: companySparkData.sparkID,
            opportunityId: this.opportunityId
          })
            .then((result) => {
              if (result != null) {
                this.blackListResponseJSON = result;
                let blackListData = JSON.parse(result);
                updateSparkDataFields(
                  this.sparkData,
                  this.sfAccount.Id,
                  this.opportunityId,
                  blackListData,
                  this.sfLeaderContacts,
                  this.counterparty.litersPrediction
                );
                this.credit.blackListDecision = blackListData.decision;
                this.startApprovalProcessRMDName(blackListData.decisionCode);
                this.getCreditData(companySparkData);
              } else {
                this.isLoadingContent = false;
              }
            })
            .catch((error) => {
              this.isLoadingContent = false;
              this.handleError(error);
            });
        } else {
          this.isLoadingContent = false;
          alert(this.labels.INN_NOT_EXIST);
        }
      })
      .catch((error) => {
        this.isLoadingContent = false;
        this.handleError(error);
      });
  }

  processSoleProprietorCheck() {
    this.isLoadingContent = true;
    getSoleProprietorSparkData({ inn: this.counterparty.iNN })
      .then((result) => {
        if (result != null) {
          this.sparkResponseJSON = result;
          let soleProprietorSparkData = JSON.parse(result);
          this.processSparkData(soleProprietorSparkData);
          this.applySparkDataToCounterparty();
          this.template
            .querySelector("c-counterparty-data")
            .disableSPARKFields(true);
          getBlackListData({
            inn: soleProprietorSparkData.inn,
            sparkID: soleProprietorSparkData.sparkID,
            opportunityId: this.opportunityId
          })
            .then((result) => {
              if (result != null) {
                this.blackListResponseJSON = result;
                let blackListData = JSON.parse(result);
                updateSparkDataFields(
                  this.sparkData,
                  this.sfAccount.Id,
                  this.opportunityId,
                  blackListData,
                  null,
                  null
                );
                this.credit.blackListDecision = blackListData.decision;
                this.startApprovalProcessRMDName(blackListData.decisionCode);
              }
            })
            .catch((error) => {
              this.handleError(error);
            })
            .finally(() => {
              this.isLoadingContent = false;
            });
        } else {
          this.isLoadingContent = false;
          alert(this.labels.INN_NOT_EXIST);
        }
      })
      .catch((error) => {
        this.isLoadingContent = false;
        this.handleError(error);
      });
  }

  getCreditData(companySparkData) {
    let promises = [];
    promises.push(
      getSparkArbitrationSummaryList({ sparkID: companySparkData.sparkID })
    );
    promises.push(
      getSparkExecutionProceedings({ sparkID: companySparkData.sparkID })
    );
    promises.push(
      getSparkFinancialReports({
        sparkID: companySparkData.sparkID,
        inn: this.sparkData.iNN
      })
    );
    promises.push(getSparkRiskReport({ sparkID: companySparkData.sparkID }));
    Promise.all(promises)
      .then((result) => {
        if (result != null) {
          this.sparkResponseJSONFull = JSON.stringify({
            companyData: companySparkData,
            financialReports: JSON.parse(result[2]),
            riskReport: JSON.parse(result[3]),
            executionProceedings: JSON.parse(result[1]),
            arbitrationSummaryList: JSON.parse(result[0])
          });
          getPreScoringData({
            fullSparkData: this.sparkResponseJSONFull,
            turnover: +this.counterparty.litersPrediction
          })
            .then((result) => {
              if (result != null) {
                this.preScoringResponseJSON = result;
                let preScoringData = JSON.parse(result);
                this.credit.preScoringDecision =
                  preScoringData.decisionString +
                  ", " +
                  this.labels.CREDIT_PERIOD +
                  " - " +
                  preScoringData.creditPeriod +
                  ", " +
                  this.labels.PAYMENT_TIME_LIMIT +
                  " - " +
                  preScoringData.paymentTimeLimit +
                  ", " +
                  this.labels.CREDIT_LIMIT +
                  " - " +
                  preScoringData.overdraft;
                this.credit.preScoringExpirationDate =
                  preScoringData.expireDate;
                this.preScoringOverdraft = preScoringData.overdraft;
                upsertCreditFactoryFields(
                  preScoringData,
                  this.opportunityId,
                  this.sfAccount.Id,
                  this.russianCreditCheckRecordTypeId,
                  this.labels.PRESCORING,
                  this.sfCreditFactoryReports?.Id
                );
              }
            })
            .catch((error) => {
              this.handleError(error);
            })
            .finally(() => {
              this.isLoadingContent = false;
            });
        } else {
          this.isLoadingContent = false;
        }
      })
      .catch((error) => {
        this.isLoadingContent = false;
        this.handleError(error);
      });
  }

  processSparkData(companySparkData) {
    this.sparkData.name = companySparkData.fullNameRus;
    this.sparkData.iNN = companySparkData.inn;
    this.sparkData.okVED = companySparkData.mainOkved.code;
    this.sparkData.oKPO = companySparkData.okpo;
    if (companySparkData.inn.length == 10) {
      this.sparkData.kPP = companySparkData.kpp;
      this.sparkData.oGRN = companySparkData.ogrn;
      let sparkAddress = companySparkData.legalAddresses.address;
      this.sparkData.legalAddress =
        sparkAddress.postCode + ", " + sparkAddress.address;
      companySparkData.legalAddresses.address.address;
      this.sparkData.legalAddressAsObject = mapSparkAddressIntoAddress(
        companySparkData.legalAddresses.address
      );
      this.sparkData.leaderFullName = companySparkData.actualLeader.fio;
      this.sparkData.leaderPosition = companySparkData.actualLeader.position;
    } else {
      this.sparkData.oGRN = companySparkData.ogrnip;
      this.sparkData.kPP = "";
      this.sparkData.legalAddress = "";
      this.sparkData.leaderFullName = "";
      this.sparkData.leaderPosition = "";
      this.credit.preScoringDecision = "";
      this.credit.preScoringExpirationDate = "";
    }
  }

  handleBankDataChange(event) {
    this.bankData[event.detail.field] = event.detail.value;
  }

  handleError(error) {
    alert(this.labels.SYSTEM_EXCEPTION);
    console.log("Exception");
    console.log(error);
  }

  async handleStartDeduplication() {
    if (
      this.contact.email != null &&
      this.contact.phoneNumber != null &&
      this.counterparty.iNN != null &&
      this.opportunityId != null &&
      this.sfAccount != null
    ) {
      this.isLoadingContent = true;
      const deduplicationFields = {
        counterpartyInn: this.counterparty.iNN,
        contactEmail: this.contact.email,
        opportunityId: this.opportunityId,
        accountId: this.sfAccount.Id,
        sfPrimaryContact: this.sfPrimaryContact,
        deduplicationStatus: this.deduplicationStatus,
        customSettingNames: this.customSettingNames
      };
      let result = await startDeduplication(deduplicationFields);
      this.approvalProcessNameToStart = await approvalProcessNameForStart;
      this.isDisabledApprovalProcess = await isDisabledApprovalButton;
      this.deduplicationResult = await deduplicationResult;
      this.isLoadingContent = false;
      return result;
    }
  }

  handleCheckDeduplicationData(email, INN, phone) {
    this.isDisabled =
      new RegExp(this.pattern.iNN).test(INN) &&
      new RegExp(this.pattern.email).test(email) &&
      new RegExp(this.pattern.phone).test(phone)
        ? false
        : true;
  }

  async handleStartSaving() {
    let invalidSections = getInavlidForSavingSections(
      this.template,
      this.childCompToLabelMap
    );
    if (invalidSections.length > 0) {
      let message =
        this.labels.CHECK_SECTIONS + ' "' + invalidSections.join(", ") + '"';
      alert(message);
    } else {
      this.isLoadingContent = true;
      if (await this.startSavingProcess()) {
        alert(this.labels.DATA_SAVED_SUCCESSFULLY);
      } else {
        console.log("Can't save client data");
      }
      this.isLoadingContent = false;
    }
  }

  async startSavingProcess() {
    let saveResult;
    let formData = {
      counterparty: this.counterparty,
      bankData: this.bankData,
      deliveryInfo: this.deliveryInfo,
      profile: this.profile,
      sfAccount: this.sfAccount,
      tariffAndServices: this.tariffAndServices,
      contractData: this.contractData,
      electronicDocumentData: this.electronicDocumentData,
      sfOpportunity: this.sfOpportunity,
      contact: this.contact,
      sfPrimaryContact: this.sfPrimaryContact,
      sfLeaderContacts: this.sfLeaderContacts
    };
    let mappedData = mapDataForSaving(formData);

    await updateSfData(mappedData)
      .then((cntData) => {
        if (cntData.primaryContact != null) {
          this.sfPrimaryContact = cntData.primaryContact;
        }
        if (cntData.leaderContact != null) {
          this.sfLeaderContacts.push(cntData.leaderContact);
        }
        saveResult = true;
      })
      .catch((err) => {
        this.isLoadingContent = false;
        this.handleError(err);
        saveResult = false;
      });
    return saveResult;
  }

  handleApprovalProcess() {
    this.isLoadingContent = true;
    if (
      this.approvalProcessNameToStart ==
      this.customSettingNames.Approval_Process_Name__c
    ) {
      this.isDisabledRMDApprovalProcess = true;
    } else {
      this.isDisabledAppruvalProcess = true;
    }
    checkForApproval({
      approvalName: this.approvalProcessNameToStart,
      opportunityId: this.opportunityId
    })
      .then((result) => {
        this.isLoadingContent = false;
        if (result != null) {
          result
            ? this.showToast("success", this.labels.OPPORTUNITY_HAS_BEEN_SEND)
            : this.showToast("info", this.labels.OPPORTUNITY_IS_PENDING);
        } else {
          this.showToast("error", this.labels.FAILED_TO_SEND);
        }
      })
      .catch((error) => {
        this.isLoadingContent = false;
        this.handleError(error);
      });
  }

  showToast(toastType, toastMessage) {
    this.template
      .querySelector("c-custom-toast")
      .showToast(toastType, toastMessage);
  }

  async startApprovalProcessRMDName(decisionCode) {
    if (decisionCode == 1 || decisionCode == 4) {
      let result = await this.isRMDApproved();
      if (!result) {
        this.approvalProcessNameToStart = this.customSettingNames.Approval_Process_Name__c;
        this.isDisabledRMDApprovalProcess = false;
      } else {
        this.credit.blackListDecision = this.labels.RMD_RESULT_APPROVED;
      }
    }
  }

  //Return true if RMD approve process found and result approved
  async isRMDApproved() {
    const APPROVED = 'Approved';
    let isApproved = false;
     await getApprovalProcesses({ id: this.opportunityId })
      .then(result => {
        if (result != null) {
          isApproved = result[this.customSettingNames.Approval_Process_Name__c] == APPROVED;
        }
      })
      .catch(error => {
        this.handleError(error);
        return isApproved;
      })
    return isApproved;
  }

  handleCloseModal() {
    this.isModalOpen = false;
  }

  handleCreateClientClick() {
    this.isModalOpen = true;
  }

  async handleCreateClient() {
    this.handleCloseModal();
    const RMD_OK = "OK";
    this.isSendToDirectum = true;

    let invalidSections = getInavlidForSavingSections(
      this.template,
      this.childCompToLabelMap,
      false
    );
    if (invalidSections.length > 0) {
      let message =
        this.labels.CHECK_SECTIONS + ' "' + invalidSections.join(", ") + '"';
      alert(message);
      this.isSendToDirectum = false;
      return;
    }

    const isLocked = await isRecordLockedByApprovalProces({
      id: this.opportunityId
    });
    if (isLocked) {
      this.showToast("error", this.labels.LOCKED_BY_APPROVAL_PROCESS);
      this.isSendToDirectum = false;
      return;
    }

    const isDeduplicationFound = await this.handleStartDeduplication();
    console.log('applicationWithOrganizationRequisite.isDeduplicationFound = ',isDeduplicationFound);
    if (isDeduplicationFound && this.sfPrimaryContact != null) {
      console.log('applicationWithOrganizationRequisite.deduplicationResult = ',this.deduplicationResult);
      this.showToast("info", this.labels.SEND_OPPORTUNITY_FOR_APPROVAL);
      this.isSendToDirectum = false;
      return;
    } else if (!isDeduplicationFound && this.sfPrimaryContact == null) {
      return (this.isSendToDirectum = false);
    }

    const data = await this.handleCheckCompany();
    if (data) {
      if ((this.credit.blackListDecision != RMD_OK) || (this.credit.blackListDecision != this.labels.RMD_RESULT_APPROVED)) {
        this.showToast("info", this.labels.BLACK_LIST_DECISION_FOUND);
        this.isSendToDirectum = false;
        return;
      }
   }

    const isSuccessSave = await this.startSavingProcess();
    if (!isSuccessSave) {
      this.isSendToDirectum = false;
      return;
    }

    await this.createClientBody();

    createDirectumContract({ requestBody: this.requestBody })
      .then((result) => {
        this.isSendToDirectum = false;
        result
          ? this.showToast("success", this.labels.REQUEST_DIRECTUM)
          : this.showToast("error", this.labels.REQUEST_DIRECTUM_FAIL);
      })
      .catch((error) => {
        this.isSendToDirectum = false;
        this.handleError(error);
      });
  }

  async createClientBody() {
    const directumFields = {
      counterparty: this.counterparty,
      bankData: this.bankData,
      contact: this.contact,
      requestBody: this.requestBody,
      profile: this.profile,
      tariffAndServices: this.tariffAndServices,
      opportunityId: this.opportunityId,
      contractData: this.contractData,
      preScoringOverdraft: this.preScoringOverdraft
    };
    await mapFieldsForDirectum(directumFields);
  }

  exportExcel() {
    let fileName =
      this.counterparty.iNN +
      "_" +
      this.counterparty.name +
      "_" +
      getFormattedDate("ru");
    exportData(this, fileName, "worksheet", "ru");
  }
}
