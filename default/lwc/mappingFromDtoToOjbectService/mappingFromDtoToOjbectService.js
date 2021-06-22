import ACCOUNT_NAME_FIELD from "@salesforce/schema/Account.Name";
import ACCOUNT_ID_FIELD from "@salesforce/schema/Account.Id";
import ACCOUNT_INN_FIELD from "@salesforce/schema/Account.INN__c";
import ACCOUNT_KPP_FIELD from "@salesforce/schema/Account.KPP__c";
import ACCOUNT_BANK_FIELD from "@salesforce/schema/Account.Bank__c";
import ACCOUNT_CHECKING_FIELD from "@salesforce/schema/Account.Checking_Account__c";
import ACCOUNT_COR_ACC_FIELD from "@salesforce/schema/Account.Cor_bank_account__c";
import ACCOUNT_CODE_WORD_FIELD from "@salesforce/schema/Account.Code_Word__c";
import ACCOUNT_BILLING_POSTAL_CODE_FIELD from "@salesforce/schema/Account.BillingPostalCode";
import ACCOUNT_BILLING_STREET_FIELD from "@salesforce/schema/Account.BillingStreet";
import ACCOUNT_BILLING_CITY_FIELD from "@salesforce/schema/Account.BillingCity";
import ACCOUNT_CUSTOM_BILLING_STATE_FIELD from "@salesforce/schema/Account.CustomBillingState__c";
import ACCOUNT_CUSTOM_BILLING_AREA_FIELD from "@salesforce/schema/Account.CustomBillingArea__c";
import ACCOUNT_SHIPPING_POSTAL_CODE_FIELD from "@salesforce/schema/Account.ShippingPostalCode";
import ACCOUNT_SHIPPING_CITY_FIELD from "@salesforce/schema/Account.ShippingCity";
import ACCOUNT_SHIPPING_STREET_FIELD from "@salesforce/schema/Account.ShippingStreet";
import ACCOUNT_CUSTOM_SHIPPING_STATE_FIELD from "@salesforce/schema/Account.CustomShippingState__c";
import ACCOUNT_OGRN_PPR_FIELD from "@salesforce/schema/Account.OGRN_ppr__c";
import ACCOUNT_OKVED_FIELD from "@salesforce/schema/Account.OKVED__c";
import ACCOUNT_OKPO_PPR_FIELD from "@salesforce/schema/Account.OKPO_ppr__c";
import ACCOUNT_ADRESS_DILIVERY_FIELD from "@salesforce/schema/Account.Adress_delivery__c";
import ACCOUNT_ORIGNAL_DOCUMENT_INFO_FIELD from "@salesforce/schema/Account.Original_document_courier_info__c";
import ACCOUNT_CARD_DILIVERY_COURIER_INFO_FIELD from "@salesforce/schema/Account.Cards_delivery_courier_info__c";
import ACCOUNT_SWIFT_BIC_FIELD from "@salesforce/schema/Account.SWIFT_BIC__c";
import ACCOUNT_BLACK_LIST_DECISION_FIELD from "@salesforce/schema/Account.Black_list_check_decision__c";

import OPPORTUNITY_ID from "@salesforce/schema/Opportunity.Id";
import OPPORTUNITY_PROJECTED_LITERS_FIELD from "@salesforce/schema/Opportunity.Projected_Liters_weekly__c";
import OPPORTUNITY_NUMBER_OF_CARS from "@salesforce/schema/Opportunity.Number_of_cars__c";
import OPPORTUNITY_NUMBER_OF_TRUCKS_FIELD from "@salesforce/schema/Opportunity.Number_of_trucks__c";
import OPPORTUNITY_SOURCE_PP_FIELD from "@salesforce/schema/Opportunity.Source_PP__c";
import OPPORTUNITY_SOURCE_OF_LEAD_FIELD from "@salesforce/schema/Opportunity.Source_of_Lead_o__c";
import OPPORTUNITY_NUMBER_OF_CARDS_FIELD from "@salesforce/schema/Opportunity.Number_of_Cards__c";
import OPPORTUNITY_NUMBER_BUSINESS_CARD_FIELD from "@salesforce/schema/Opportunity.Number_Business_CARD__c";
import OPPORTUNITY_PROMO_CAMPAIGHN_FIELD from "@salesforce/schema/Opportunity.Promo_campaign__c";
import OPPORTUNITY_PROMO_CODE_FIELD from "@salesforce/schema/Opportunity.Promo_Code1__c";
import OPPORTUNITY_VIRTUAL_CARDS_FIELD from "@salesforce/schema/Opportunity.Virtual_cards__c";
import OPPORTUNITY_PAID_PERSONAL_MANAGER_FIELD from "@salesforce/schema/Opportunity.Paid_personal_manager__c";
import OPPORTUNITY_PRODUCT_PPR_FIELD from "@salesforce/schema/Opportunity.Product_PPR__c";
import OPPORTUNITY_EDM_FIELD from "@salesforce/schema/Opportunity.PPR_Electronic_document_management__c";
import OPPORTUNITY_EXPRESS_DILIVERY_DOC_FIELD from "@salesforce/schema/Opportunity.Express_delivery_documents__c";
import OPPORTUNITY_AMOUNT_PAYMENT_FIELD from "@salesforce/schema/Opportunity.Amount_payment__c";
import OPPORTUNITY_OUR_ORGANIZATION_FIELD from "@salesforce/schema/Opportunity.Our_organization__c";
import OPPORTUNITY_CATEGORY_CONTRACT_FIELD from "@salesforce/schema/Opportunity.CategoryContract__c";
import OPPORTUNITY_SUBJECT_CONTRACT_FIELD from "@salesforce/schema/Opportunity.Subject_contract__c";
import OPPORTUNITY_NOTE_CONTRACT_FIELD from "@salesforce/schema/Opportunity.Note_contract__c";
import OPPORTUNITY_STANDARD_CONTRACT_FIELD from "@salesforce/schema/Opportunity.Standard_contract__c";
import OPPORTUNITY_CONTRACT_AMMOUNT_FIELD from "@salesforce/schema/Opportunity.Contract_amount__c";

import CONTACT_OBJECT from "@salesforce/schema/Contact";
import CONTACT_ID_FIELD from "@salesforce/schema/Contact.Id";
import CONTACT_ACCOUNT_ID_FIELD from "@salesforce/schema/Contact.AccountId";
import CONTACT_PHONE_FIELD from "@salesforce/schema/Contact.Phone";
import CONTACT_EMAIL_FIELD from "@salesforce/schema/Contact.Email";
import CONTACT_LAST_NAME_FIELD from "@salesforce/schema/Contact.LastName";
import CONTACT_FIRST_NAME_FIELD from "@salesforce/schema/Contact.FirstName";
import CONTACT_MIDDLE_NAME_FIELD from "@salesforce/schema/Contact.MiddleName";
import CONTACT_ADDITIONAL_EMAIL_FIELD from "@salesforce/schema/Contact.Additional_Emails__c";
import CONTACT_ADDITIONAL_PHONE_FIELD from "@salesforce/schema/Contact.Additional_Phones__c";
import CONTACT_TITLE_FIELD from "@salesforce/schema/Contact.Title";

import CREDIT_FACTORY_OBJECT from "@salesforce/schema/Credit_Factory_Report__c";
import CREDIT_FACTORY_NAME from "@salesforce/schema/Credit_Factory_Report__c.Name";
import CREDIT_FACTORY_RECORD_TYPE_ID_FIELD from "@salesforce/schema/Credit_Factory_Report__c.RecordTypeId";
import CREDIT_FACTORY_ACCOUNT_ID from "@salesforce/schema/Credit_Factory_Report__c.Account__c";
import CREDIT_FACTORY_OPPORTUNITY_ID from "@salesforce/schema/Credit_Factory_Report__c.Opportunity__c";
import CREDIT_FACTORY_ID_FIELD from "@salesforce/schema/Credit_Factory_Report__c.Id";
import CREDIT_FACTORY_SCORING_DECISION_FIELD from "@salesforce/schema/Credit_Factory_Report__c.RU_scoring_decision__c";
import CREDIT_FACTORY_SCORING_EXPIRATION_DATE_FIELD from "@salesforce/schema/Credit_Factory_Report__c.RU_Scoring_expiration_date__c";
import CREDIT_FACTORY_SCORING_DATE from "@salesforce/schema/Credit_Factory_Report__c.RU_Scoring_date__c";
import CREDIT_FACTORY_LIMIT_FIELD from "@salesforce/schema/Credit_Factory_Report__c.Credit_Limit__c";
import CREDIT_FACTORY_SCORING_TIME_LIMIT_DATE_FIELD from "@salesforce/schema/Credit_Factory_Report__c.RU_Scoring_Payment_Time_Limit__c";
import CREDIT_FACTORY_SCORING_CREDIT_PERIOD_FIELD from "@salesforce/schema/Credit_Factory_Report__c.RU_Scoring_Credit_Period__c";
import CREDIT_FACTORY_SCORING_TYPE_FIELD from "@salesforce/schema/Credit_Factory_Report__c.RU_scoring_type__c";

import {
  replaceExtraSpaces,
  parseContactFullName,
  mergeContactFullNameInRussianFormat
} from "c/textUtils";

const PRESCORING = "Prescoring";

const mapAccountForSaving = (
  counterpartyData,
  bankData,
  deliveryinfo,
  profile,
  accountId
) => {
  let fields = {};
  fields[ACCOUNT_ID_FIELD.fieldApiName] = accountId;
  fields[ACCOUNT_CODE_WORD_FIELD.fieldApiName] = profile.codeWord;
  fields = mapCounterpartyDataOrSparkDataIntoAccFields(counterpartyData, fields);
  fields = mapBankDataIntoAccFields(bankData, fields);
  fields = mapDeliveryInfoIntoAccFields(deliveryinfo, fields);
  const accForUpdate = { fields };

  return accForUpdate;
};

const mapCounterpartyDataOrSparkDataIntoAccFields = (data, fields) => {
  let accFields = fields;
  let legalAddress = data.legalAddressAsObject;
  let postalAddress = data.postalAddressAsObject ? data.postalAddressAsObject : [];
  if (Object.keys(legalAddress).length !== 0) {
    accFields[ACCOUNT_BILLING_POSTAL_CODE_FIELD.fieldApiName] =
      legalAddress.postalCode;
    accFields[ACCOUNT_BILLING_CITY_FIELD.fieldApiName] = legalAddress.city;
    accFields[ACCOUNT_BILLING_STREET_FIELD.fieldApiName] =
      legalAddress.streetWithHouse;
    accFields[ACCOUNT_CUSTOM_BILLING_STATE_FIELD.fieldApiName] =
      legalAddress.state.toUpperCase();
    accFields[ACCOUNT_CUSTOM_BILLING_AREA_FIELD.fieldApiName] =
      legalAddress.area.toUpperCase();
  }

  if (Object.keys(postalAddress).length !== 0) {
    accFields[ACCOUNT_SHIPPING_POSTAL_CODE_FIELD.fieldApiName] =
      postalAddress.postalCode;
    accFields[ACCOUNT_SHIPPING_CITY_FIELD.fieldApiName] = postalAddress.city;
    accFields[ACCOUNT_SHIPPING_STREET_FIELD.fieldApiName] =
      postalAddress.streetWithHouse;
    accFields[ACCOUNT_CUSTOM_SHIPPING_STATE_FIELD.fieldApiName] =
      postalAddress.state.toUpperCase();
  }

  accFields[ACCOUNT_NAME_FIELD.fieldApiName] = data.name;
  accFields[ACCOUNT_INN_FIELD.fieldApiName] = data.iNN;
  accFields[ACCOUNT_KPP_FIELD.fieldApiName] = data.kPP;
  accFields[ACCOUNT_OGRN_PPR_FIELD.fieldApiName] = data.oGRN;
  accFields[ACCOUNT_OKVED_FIELD.fieldApiName] = data.okVED;
  accFields[ACCOUNT_OKPO_PPR_FIELD.fieldApiName] = data.oKPO;

  return accFields;
};

const mapBankDataIntoAccFields = (bankData, fields) => {
  let accFields = fields;
  accFields[ACCOUNT_BANK_FIELD.fieldApiName] = bankData.bankName;
  accFields[ACCOUNT_CHECKING_FIELD.fieldApiName] = bankData.checkingAccount;
  accFields[ACCOUNT_COR_ACC_FIELD.fieldApiName] = bankData.corBankAccount;
  accFields[ACCOUNT_SWIFT_BIC_FIELD.fieldApiName] = bankData.bankBic;
  return accFields;
};

const mapDeliveryInfoIntoAccFields = (deliveryInfo, fields) => {
  let accFields = fields;
  accFields[ACCOUNT_CARD_DILIVERY_COURIER_INFO_FIELD.fieldApiName] =
    deliveryInfo.cardsDeliveryCourierInfo;
  accFields[ACCOUNT_ADRESS_DILIVERY_FIELD.fieldApiName] =
    deliveryInfo.shippingAddress;
  accFields[ACCOUNT_ORIGNAL_DOCUMENT_INFO_FIELD.fieldApiName] =
    deliveryInfo.originalDocumentCourierInfo;
  return accFields;
};

const mapOpportunityForSaving = (
  counterpartyData,
  tariffAndServices,
  contractData,
  oppId,
  electronicDocumentData,
  profile
) => {
  let fields = {};
  fields[OPPORTUNITY_ID.fieldApiName] = oppId;
  fields = mapCounterpartyDataIntoOppFields(counterpartyData, fields);
  fields = mapTariffAndServicesIntoOppFields(tariffAndServices, fields);
  fields = mapContractDataIntoOppFields(contractData, fields);
  fields = mapProfileDataIntoOppFields(profile, fields);

  fields[OPPORTUNITY_EDM_FIELD.fieldApiName] =
    electronicDocumentData.electronicDocument;
  const oppForUpdate = { fields };
  return oppForUpdate;
};

const mapCounterpartyDataIntoOppFields = (counterpartyData, fields) => {
  let oppFields = fields;
  oppFields[OPPORTUNITY_PROJECTED_LITERS_FIELD.fieldApiName] =
    counterpartyData.litersPrediction;
  oppFields[OPPORTUNITY_NUMBER_OF_CARS.fieldApiName] =
    counterpartyData.carCount;
  oppFields[OPPORTUNITY_NUMBER_OF_TRUCKS_FIELD.fieldApiName] =
    counterpartyData.truckCount;
  oppFields[OPPORTUNITY_SOURCE_PP_FIELD.fieldApiName] =
    counterpartyData.partnerProgram;
  oppFields[OPPORTUNITY_SOURCE_OF_LEAD_FIELD.fieldApiName] =
    counterpartyData.searchChannel;
  return oppFields;
};

const mapTariffAndServicesIntoOppFields = (tariffAndServices, fields) => {
  let oppFields = fields;
  oppFields[OPPORTUNITY_NUMBER_BUSINESS_CARD_FIELD.fieldApiName] =
    tariffAndServices.cardsAmountBK;
  oppFields[OPPORTUNITY_NUMBER_OF_CARDS_FIELD.fieldApiName] =
    tariffAndServices.cardsAmountTK;
  oppFields[OPPORTUNITY_PROMO_CAMPAIGHN_FIELD.fieldApiName] =
    tariffAndServices.selectedPromocode;
  oppFields[OPPORTUNITY_PROMO_CODE_FIELD.fieldApiName] =
    tariffAndServices.selectedAdditionalPromocode;
  oppFields[OPPORTUNITY_VIRTUAL_CARDS_FIELD.fieldApiName] =
    tariffAndServices.virtualCardsSelected;
  oppFields[OPPORTUNITY_PAID_PERSONAL_MANAGER_FIELD.fieldApiName] =
    tariffAndServices.personalConsultantSelected;
  oppFields[OPPORTUNITY_PRODUCT_PPR_FIELD.fieldApiName] =
    tariffAndServices.selectedTariff;
  oppFields[OPPORTUNITY_EXPRESS_DILIVERY_DOC_FIELD.fieldApiName] =
    tariffAndServices.documentsExpressDeliverySelected;
  return oppFields;
};

const mapContractDataIntoOppFields = (contractData, fields) => {
  let oppFields = fields;
  oppFields[OPPORTUNITY_AMOUNT_PAYMENT_FIELD.fieldApiName] =
    contractData.amountPayment;
  oppFields[OPPORTUNITY_OUR_ORGANIZATION_FIELD.fieldApiName] =
    contractData.organization;
  oppFields[OPPORTUNITY_CATEGORY_CONTRACT_FIELD.fieldApiName] =
    contractData.categoryOfСontract;
  oppFields[OPPORTUNITY_SUBJECT_CONTRACT_FIELD.fieldApiName] =
    contractData.сontractSubject;
  oppFields[OPPORTUNITY_NOTE_CONTRACT_FIELD.fieldApiName] =
    contractData.contractNote;
  oppFields[OPPORTUNITY_STANDARD_CONTRACT_FIELD.fieldApiName] =
    contractData.standardСontractSelected;
  oppFields[OPPORTUNITY_CONTRACT_AMMOUNT_FIELD.fieldApiName] =
    contractData.contractAmount;
  return oppFields;
};

const mapProfileDataIntoOppFields = (profile, fields) => {
  let oppFields = fields;

  return oppFields;
};

const mapPrimaryContactForSaving = (
  contactData,
  profile,
  accountId,
  primaryContact
) => {
  let fields = {};
  let primaryContactForUpdate = {};
  fields[CONTACT_ACCOUNT_ID_FIELD.fieldApiName] = accountId;
  fields = mapContactCompIntoPrimaryContactFields(contactData, fields);
  fields[CONTACT_ADDITIONAL_EMAIL_FIELD.fieldApiName] = profile.email;
  fields[CONTACT_ADDITIONAL_PHONE_FIELD.fieldApiName] = profile.phoneNumber;
  if (primaryContact != null) {
    fields[CONTACT_ID_FIELD.fieldApiName] = primaryContact.Id;
    primaryContactForUpdate = { fields };
  } else {
    primaryContactForUpdate = {
      apiName: CONTACT_OBJECT.objectApiName,
      fields: fields
    };
  }
  return primaryContactForUpdate;
};

const mapContactCompIntoPrimaryContactFields = (contactData, fields) => {
  let cntFields = fields;
  let dividedContactNames = parseContactFullName(contactData.fullName);
  cntFields[CONTACT_PHONE_FIELD.fieldApiName] = contactData.phoneNumber;
  cntFields[CONTACT_EMAIL_FIELD.fieldApiName] = contactData.email;
  cntFields[CONTACT_LAST_NAME_FIELD.fieldApiName] = dividedContactNames[0];
  cntFields[CONTACT_FIRST_NAME_FIELD.fieldApiName] =
    dividedContactNames[1] != null ? dividedContactNames[1] : "";
  cntFields[CONTACT_MIDDLE_NAME_FIELD.fieldApiName] =
    dividedContactNames[2] != null ? dividedContactNames[2].toUpperCase() : "";
  cntFields[CONTACT_TITLE_FIELD.fieldApiName] = contactData.position;
  return cntFields;
};

const mapLeaderContactForSaving = (
  counterparyData,
  leaderContacts,
  accountId
) => {
  let fields = {};
  let leaderContactForUpdate = {};
  let leaderContact = findLeaderContactByName(
    leaderContacts,
    counterparyData.leaderFullName
  );

  fields[CONTACT_ACCOUNT_ID_FIELD.fieldApiName] = accountId;
  fields = mapCounterpartyDataIntoLeaderContactFields(counterparyData, fields);
  if (leaderContact != null) {
    fields[CONTACT_ID_FIELD.fieldApiName] = leaderContact.Id;
    leaderContactForUpdate = { fields };
  } else {
    leaderContactForUpdate = {
      apiName: CONTACT_OBJECT.objectApiName,
      fields: fields
    };
  }
  return leaderContactForUpdate;
};

const findLeaderContactByName = (leaderContacts, fullName) => {
  let leaderContact = null;
  for (let contact of leaderContacts) {
    let cntName = mergeContactFullNameInRussianFormat(
      contact.LastName,
      contact.FirstName,
      contact.MiddleName
    );
    let counterpartyCntName = replaceExtraSpaces(fullName, " ");
    if (cntName.toLowerCase() == counterpartyCntName.toLowerCase()) {
      leaderContact = contact;
      break;
    }
  }
  return leaderContact;
};

const mapCounterpartyDataIntoLeaderContactFields = (
  counterpartyData,
  fields
) => {
  let cntFields = fields;
  let dividedContactNames = parseContactFullName(
    counterpartyData.leaderFullName
  );
  cntFields[CONTACT_LAST_NAME_FIELD.fieldApiName] = dividedContactNames[0];
  cntFields[CONTACT_FIRST_NAME_FIELD.fieldApiName] =
    dividedContactNames[1] != null ? dividedContactNames[1] : "";
  cntFields[CONTACT_MIDDLE_NAME_FIELD.fieldApiName] =
    dividedContactNames[2] != null ? dividedContactNames[2] : "";
  cntFields[CONTACT_TITLE_FIELD.fieldApiName] = counterpartyData.leaderPosition;
  return cntFields;
};

const mapDataForSaving = (formData) => {
  let account = mapAccountForSaving(
    formData.counterparty,
    formData.bankData,
    formData.deliveryInfo,
    formData.profile,
    formData.sfAccount.Id
  );
  let opportunity = mapOpportunityForSaving(
    formData.counterparty,
    formData.tariffAndServices,
    formData.contractData,
    formData.sfOpportunity.Id,
    formData.electronicDocumentData
  );
  let primaryContact = mapPrimaryContactForSaving(
    formData.contact,
    formData.profile,
    formData.sfAccount.Id,
    formData.sfPrimaryContact
  );
  let leaderContact = null;
  if (
    !checkIfPrimaryContactAsLeader(
      formData.contact.fullName,
      formData.counterparty.leaderFullName
    )
  ) {
    leaderContact = mapLeaderContactForSaving(
      formData.counterparty,
      formData.sfLeaderContacts,
      formData.sfAccount.Id
    );
  }
  let data = {
    account: account,
    opportunity: opportunity,
    primaryContact: primaryContact,
    leaderContact: leaderContact
  };
  return data;
};

const checkIfPrimaryContactAsLeader = (primaryCntName, leaderCntName) => {
  let formatedPrimaryCntName = replaceExtraSpaces(
    primaryCntName,
    ""
  ).toLowerCase();
  let formatedLeaderCntName = replaceExtraSpaces(
    leaderCntName,
    ""
  ).toLowerCase();
  return formatedPrimaryCntName == formatedLeaderCntName;
};

const mapSparkDataFields = (
  sparkData,
  accountId,
  opportunityId,
  blackListData,
  leaderContacts,
  litersPrediction
) => {

  let recordInput = {};
  let oppFields = {};
  let fields = {};

  fields[ACCOUNT_ID_FIELD.fieldApiName] = accountId;
  fields[ACCOUNT_BLACK_LIST_DECISION_FIELD.fieldApiName] = blackListData.decision;
  fields = mapCounterpartyDataOrSparkDataIntoAccFields(sparkData, fields);

  if (litersPrediction != null) {
    oppFields[OPPORTUNITY_ID.fieldApiName] = opportunityId;
    oppFields[OPPORTUNITY_PROJECTED_LITERS_FIELD.fieldApiName] = litersPrediction;
    recordInput = mapLeaderContactForSaving(sparkData, leaderContacts, accountId);
  }

  return { ...fields, recordInput, oppFields };
};

const mapCreditFactoryFields = (
  preScoringData,
  opportunityId,
  accountId,
  russianCreditCheckRecordTypeId,
  prescoring,
  creditFactoryId,
  scoringDecision
) => {

  let fields = {};
  let expirationDate = preScoringData.expireDate.split(".").reverse().join("-");
  let dateRequest = preScoringData.dateRequest.split(".").reverse().join("-");

  fields[CREDIT_FACTORY_OPPORTUNITY_ID.fieldApiName] = opportunityId;
  fields[CREDIT_FACTORY_ACCOUNT_ID.fieldApiName] = accountId;
  fields[CREDIT_FACTORY_RECORD_TYPE_ID_FIELD.fieldApiName] = russianCreditCheckRecordTypeId;
  fields[CREDIT_FACTORY_NAME.fieldApiName] = prescoring;
  //todo here pass scoring type to preScoringData object from apex(when will scoring,prescoring)
  fields[CREDIT_FACTORY_SCORING_TYPE_FIELD.fieldApiName] = PRESCORING;
  fields[CREDIT_FACTORY_SCORING_DECISION_FIELD.fieldApiName] = scoringDecision;
  fields[CREDIT_FACTORY_SCORING_EXPIRATION_DATE_FIELD.fieldApiName] = new Date(expirationDate).toISOString();
  fields[CREDIT_FACTORY_SCORING_DATE.fieldApiName] = new Date(dateRequest).toISOString();
  fields[CREDIT_FACTORY_LIMIT_FIELD.fieldApiName] = preScoringData.overdraft.toString();
  fields[CREDIT_FACTORY_SCORING_TIME_LIMIT_DATE_FIELD.fieldApiName] = preScoringData.paymentTimeLimit;
  fields[CREDIT_FACTORY_SCORING_CREDIT_PERIOD_FIELD.fieldApiName] = preScoringData.creditPeriod;

  if (creditFactoryId != null) {
    fields[CREDIT_FACTORY_ID_FIELD.fieldApiName] = creditFactoryId;
    return fields;
  } else {
    const recordInput = { apiName: CREDIT_FACTORY_OBJECT.objectApiName, fields };
    return recordInput;
  }
};

export {
  mapAccountForSaving,
  mapLeaderContactForSaving,
  mapOpportunityForSaving,
  mapPrimaryContactForSaving,
  mapDataForSaving,
  mapSparkDataFields,
  mapCreditFactoryFields
};