import getApprovalProcesses from "@salesforce/apex/ApprovalService.getApprovalProcesses";
import processDeduplication from "@salesforce/apex/DeduplicationServiceLightning.processDeduplication";
import {LABELS} from "c/textUtils";
import {updateRecord} from "lightning/uiRecordApi";
import DEDUPLICATION_RESULT from "@salesforce/schema/Opportunity.Deduplication_result__c";
import DEDUPLICATION_INN_CHECK from "@salesforce/schema/Opportunity.Deduplication_inn_check__c";
import DEDUPLICATION_EMAIL_CHECK from "@salesforce/schema/Opportunity.Deduplication_email_check__c";
import DEDUPLICATION_DOMAIN_CHECK from "@salesforce/schema/Opportunity.Deduplication_domain_check__c";
import DEDUPLICATION_DATE_CHECK from "@salesforce/schema/Opportunity.Last_deduplication_check_date__c";
import ID_OPPORTUNITY from "@salesforce/schema/Opportunity.Id";

const labels = LABELS;

let approvalProcessNameForStart;
let isDisabledApprovalButton;
let deduplicationResult;

const APPROVED = 'Approved';

function handleError(error) {
  alert(this.labels.SYSTEM_EXCEPTION);
  console.log(error);
}

//return true if duplication found
//return false if no duplication found or duplication is approved
const startDeduplication = async (deduplicationFields) => {

  const {
    counterpartyInn,
    contactEmail,
    opportunityId,
    accountId,
    sfPrimaryContact,
    deduplicationStatus,
    customSettingNames
  } = deduplicationFields;

  let startDedupResult = false;
  if (sfPrimaryContact == null) {
    alert(labels.CONTACT_ERROR);
    return startDedupResult;
  }
  await processDeduplication({
    inn: counterpartyInn,
    email: contactEmail,
    opportunityId: opportunityId,
    accountId: accountId,
    contactId: sfPrimaryContact.Id
  })
    .then(async (result) => {
      if (result != null) {
        const res = JSON.parse(result);
        deduplicationResult =
          res.statusCode != deduplicationStatus
            ? labels.DEDUPLICATION_RESULT_TRUE
            : labels.DEDUPLICATION_RESULT_FALSE;
        if (res.statusCode != deduplicationStatus) {
          startDedupResult = true;
          let dedupApproveResult = await isDuplicateApproved(opportunityId, customSettingNames);
          if (dedupApproveResult) {
            deduplicationResult = labels.DEDUPLICATION_RESULT_APPROVED;
            startDedupResult = false;
          }
        }
        updateDeduplicationResult(res, opportunityId, customSettingNames);
        console.log('deduplicationService.deduplicationResult = ',deduplicationResult);
      }
    })
    .catch((error) => {
      handleError(error);
    });
  return startDedupResult;
};

const isDuplicateApproved = async (opportunityId, customSettingNames) => {
  let isApproved;
  await getApprovalProcesses({id: opportunityId})
    .then(result => {
      if (result != null) {
        isApproved = result[customSettingNames.Approval_Process_Service_Name__c] == APPROVED ||
          result[customSettingNames.Approval_Process_Admin_Name__c] == APPROVED;
      }
    })
    .catch(error => {
      handleError(error);
      isApproved = false;
    })
  return isApproved;
};

function updateDeduplicationResult(res, opportunityId, customSettingNames) {
  const fields = {};
  fields[ID_OPPORTUNITY.fieldApiName] = opportunityId;
  fields[DEDUPLICATION_RESULT.fieldApiName] = deduplicationResult;
  fields[DEDUPLICATION_INN_CHECK.fieldApiName] = res.innDuplication
    ? labels.DEDUPLICATION_RESULT_TRUE
    : labels.DEDUPLICATION_RESULT_FALSE;
  fields[DEDUPLICATION_EMAIL_CHECK.fieldApiName] = res.isEmailDuplicated
    ? labels.DEDUPLICATION_RESULT_TRUE
    : labels.DEDUPLICATION_RESULT_FALSE;
  fields[DEDUPLICATION_DOMAIN_CHECK.fieldApiName] = res.isDomainDuplicated
    ? labels.DEDUPLICATION_RESULT_TRUE
    : labels.DEDUPLICATION_RESULT_FALSE;
  fields[DEDUPLICATION_DATE_CHECK.fieldApiName] = new Date(
    res.deduplicationDatetime
  ).toISOString();
  updateRecord({fields});
  isDisabledApprovalButton = true;
  if (res.isEmailDuplicated || res.isDomainDuplicated && res.isDifferentOwnerFoundForOpportunities) {
    approvalProcessNameForStart = customSettingNames.Approval_Process_Admin_Name__c;
    isDisabledApprovalButton = false;
  } else if (res.statusCode == "Service") {
    approvalProcessNameForStart = customSettingNames.Approval_Process_Service_Name__c;
    isDisabledApprovalButton = false;
  }
  if (deduplicationResult == labels.DEDUPLICATION_RESULT_APPROVED) {
    isDisabledApprovalButton = true;
  }
};

export {
  startDeduplication,
  approvalProcessNameForStart,
  isDisabledApprovalButton,
  deduplicationResult
};