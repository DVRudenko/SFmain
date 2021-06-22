import {
  mergeContactFullNameInRussianFormat,
  applyRussianPhoneMask,
  mergeRussianAddress,
  getStringSimilarityCoeff
} from "c/textUtils";

const CURRENCY_RUB = 'RUB';
const CONTRACT_SUBJECT = 'Клиентский договор';

const mapPrimaryContactBdData = (sfPrimaryContact, contact, profile) => {
  if (sfPrimaryContact != null) {
    contact.phoneNumber = applyRussianPhoneMask(sfPrimaryContact.Phone);
    contact.email = sfPrimaryContact.Email;
    contact.fullName = mergeContactFullNameInRussianFormat(
      sfPrimaryContact.LastName,
      sfPrimaryContact.FirstName,
      sfPrimaryContact.MiddleName
    );
    contact.position = sfPrimaryContact.Title;
    profile.email = sfPrimaryContact.Additional_Emails__c;

  }
};

const mapAccountBdData = (
  sfAccount,
  counterparty,
  bankData,
  deliveryInfo,
  profile,
  credit
) => {
  if (sfAccount != null) {
    counterparty.name = sfAccount.Name;
    counterparty.iNN = sfAccount.INN__c;
    counterparty.kPP = sfAccount.KPP__c;
    counterparty.oGRN = sfAccount.OGRN_ppr__c;
    counterparty.okVED = sfAccount.OKVED__c;
    counterparty.oKPO = sfAccount.OKPO_ppr__c;
    counterparty.legalAddress = mergeRussianAddress(
      sfAccount.BillingPostalCode,
      sfAccount.CustomBillingState__c,
      sfAccount.CustomBillingArea__c,
      sfAccount.BillingCity,
      sfAccount.BillingStreet
    );

    counterparty.postalAddress = mergeRussianAddress(
      sfAccount.ShippingPostalCode,
      sfAccount.CustomShippingState__c,
      null,
      sfAccount.ShippingCity,
      sfAccount.ShippingStreet
    );
    credit.blackListDecision = sfAccount.Black_list_check_decision__c;
    bankData.bankName = sfAccount.Bank__c;
    bankData.bankBic = sfAccount.SWIFT_BIC__c;
    bankData.checkingAccount = sfAccount.Checking_Account__c;
    bankData.corBankAccount = sfAccount.Cor_bank_account__c;
    profile.codeWord = sfAccount.Code_Word__c;
    deliveryInfo.shippingAddress = sfAccount.Adress_delivery__c;
    deliveryInfo.originalDocumentCourierInfo =
      sfAccount.Original_document_courier_info__c;
    deliveryInfo.cardsDeliveryCourierInfo =
      sfAccount.Cards_delivery_courier_info__c;
  }
};

const mapOpportunityBdData = (
  sfOpportunity,
  counterparty,
  tariffAndServices,
  electronicDocumentData,
  contractData
) => {
  if (sfOpportunity != null) {
    profile.phoneNumber = applyRussianPhoneMask(
      sfOpportunity.Personal_office_phone__c
    );
    counterparty.litersPrediction = sfOpportunity.Projected_Liters_weekly__c;
    counterparty.carCount = sfOpportunity.Number_of_cars__c;
    counterparty.truckCount = sfOpportunity.Number_of_trucks__c;
    counterparty.partnerProgram = sfOpportunity.Source_PP__c;
    counterparty.searchChannel = sfOpportunity.Source_of_Lead_o__c;
    tariffAndServices.selectedTariff = sfOpportunity.Product_PPR__c;
    tariffAndServices.cardsAmount = sfOpportunity.ALL_Cards__c;
    tariffAndServices.cardsAmountTK = sfOpportunity.Number_of_Cards__c;
    tariffAndServices.cardsAmountBK = sfOpportunity.Number_Business_CARD__c;
    tariffAndServices.selectedPromocode = sfOpportunity.Promo_campaign__c;
    tariffAndServices.selectedAdditionalPromocode =
      sfOpportunity.Promo_Code1__c;
    tariffAndServices.virtualCardsSelected = sfOpportunity.Virtual_cards__c;
    tariffAndServices.personalConsultantSelected =
      sfOpportunity.Paid_personal_manager__c;
    tariffAndServices.documentsExpressDeliverySelected =
      sfOpportunity.Express_delivery_documents__c;
    electronicDocumentData.electronicDocument =
      sfOpportunity.PPR_Electronic_document_management__c;
    contractData.amountPayment = sfOpportunity.Amount_payment__c;
    contractData.organization = sfOpportunity.Our_organization__c;
    contractData.categoryOfСontract = sfOpportunity.CategoryContract__c;
    contractData.сontractSubject = sfOpportunity.Subject_contract__c;
    contractData.contractNote = sfOpportunity.Note_contract__c;
    contractData.standardСontractSelected = sfOpportunity.Standard_contract__c;
    contractData.contractAmount = sfOpportunity.Contract_amount__c;
  }
};

const mapCreditFactoryReportsBdData = (
  sfCreditFactoryReports,
  credit,
  component
) => {
  if (sfCreditFactoryReports != null) {
    credit.preScoringDecision = sfCreditFactoryReports.RU_scoring_decision__c;
    credit.preScoringExpirationDate =
      sfCreditFactoryReports.RU_Scoring_expiration_date__c;
    component.creditFactoryReportRecordTypeId =
      sfCreditFactoryReports.RecordTypeId;
    if (credit.preScoringDecision == component.scoringDecision) {
      credit.creditDecision = `${
        sfCreditFactoryReports.RU_scoring_type__c
          ? sfCreditFactoryReports.RU_scoring_type__c
          : ""
      } -
     ${
       sfCreditFactoryReports.RU_Scoring_Credit_Period__c
         ? sfCreditFactoryReports.RU_Scoring_Credit_Period__c
         : 0
     } -
     ${
       sfCreditFactoryReports.RU_Scoring_Payment_Time_Limit__c
         ? sfCreditFactoryReports.RU_Scoring_Payment_Time_Limit__c
         : 0
     } +
     ${
       sfCreditFactoryReports.Credit_Limit__c
         ? sfCreditFactoryReports.Credit_Limit__c
         : 0
     }`.replaceAll(/\s/g, "");
    } else {
      credit.creditDecision = "";
    }
  }
};

const mapDadataSelectedValueIntoAddress = (suggestion) => {
  let address = {
    postalCode: "",
    state: "",
    area: "",
    city: "",
    streetWithHouse: ""
  };

  if (suggestion != null) {
    let data = suggestion.data;
    let addressUnpasrsedStr = suggestion.unrestricted_value;
    address.postalCode = data.postal_code != null ? data.postal_code : "";
    addressUnpasrsedStr = addressUnpasrsedStr.replace(address.postalCode, "");

    address.state =
      data.region_with_type != null &&
      data.region_with_type != data.city_with_type
        ? data.region_with_type
        : "";
    addressUnpasrsedStr = addressUnpasrsedStr.replace(address.state, "");

    address.area = data.area_with_type != null ? data.area_with_type : "";
    addressUnpasrsedStr = addressUnpasrsedStr.replace(address.area, "");

    let addressCityArr = [];
    if (data.city_with_type != null) {
      addressCityArr.push(data.city_with_type);
    }
    if (data.settlement_with_type != null) {
      addressCityArr.push(data.settlement_with_type);
    }
    address.city = addressCityArr.join(", ");
    addressUnpasrsedStr = addressUnpasrsedStr.replace(address.city, "");
    addressUnpasrsedStr = addressUnpasrsedStr.replace(/^[, ]+/, "");

    address.streetWithHouse = addressUnpasrsedStr;
  }
  return address;
};

const mapSparkAddressIntoAddress = (data) => {
  let address = {
    postalCode: "",
    state: "",
    area: "",
    city: "",
    streetWithHouse: ""
  };
  if (data != null) {
    let addressArr = data.address.split(", ");

    let stateValues =
      data.region != null && data.region != data.city
        ? findSimilarStringInArr(addressArr, data.region)
        : [];
    stateValues.unshift(...findUnmatchedFields(addressArr, stateValues));
    removeFindedValuesFromStringArr(addressArr, stateValues);

    let areaValues =
      data.rayon != null ? findSimilarStringInArr(addressArr, data.rayon) : [];
    stateValues.push(...findUnmatchedFields(addressArr, areaValues));
    removeFindedValuesFromStringArr(addressArr, areaValues);

    let cityValues =
      data.city != null ? findSimilarStringInArr(addressArr, data.city) : [];
    areaValues.push(...findUnmatchedFields(addressArr, cityValues));
    removeFindedValuesFromStringArr(addressArr, cityValues);

    address.postalCode = data.postCode != null ? data.postCode : "";
    address.state = stateValues.join(", ");
    address.area = areaValues.join(", ");
    address.city = cityValues.join(", ");
    address.streetWithHouse = addressArr.join(", ");
  }
  return address;
};

const findSimilarStringInArr = (stringArr, targetString) => {
  let resultAsArr = [];
  if (targetString != null) {
    let index;
    let maxStringSimilarityCoef = 0;
    for (let i = 0; i < stringArr.length; i++) {
      let stringSimilarityCoeff = getStringSimilarityCoeff(
        targetString,
        stringArr[i]
      );
      if (stringSimilarityCoeff > maxStringSimilarityCoef) {
        maxStringSimilarityCoef = stringSimilarityCoeff;
        index = i;
      }
    }
    resultAsArr.push(stringArr[index]);

    let comparisonValue = stringArr[index];
    for (let i = index - 1; i >= 0; i--) {
      comparisonValue += stringArr[i];
      let stringSimilarityCoeff = getStringSimilarityCoeff(
        targetString,
        comparisonValue
      );
      if (stringSimilarityCoeff < maxStringSimilarityCoef) {
        comparisonValue = stringArr[index];
        break;
      }
      resultAsArr.unshift(stringArr[i]);
      maxStringSimilarityCoef = stringSimilarityCoeff;
    }

    for (let i = index + 1; i < stringArr.length; i++) {
      comparisonValue += stringArr[i];
      let stringSimilarityCoeff = getStringSimilarityCoeff(
        targetString,
        comparisonValue
      );
      if (stringSimilarityCoeff < maxStringSimilarityCoef) {
        break;
      }
      resultAsArr.push(stringArr[i]);
      maxStringSimilarityCoef = stringSimilarityCoeff;
    }
    return resultAsArr;
  }
};

const findUnmatchedFields = (stringArr, findedValues) => {
  let unmatchedFields = [];
  let stopIndex = stringArr.indexOf(findedValues[0]);
  if (stopIndex != -1) {
    for (let i = 0; i < stopIndex; i++) {
      unmatchedFields.push(stringArr[i]);
    }
  }
  return unmatchedFields;
};

const removeFindedValuesFromStringArr = (stringArr, findedValues) => {
  let stopIndex = stringArr.indexOf(findedValues[findedValues.length - 1]);
  if (stopIndex != -1) {
    for (let i = 0; i <= stopIndex; i++) {
      stringArr.shift();
    }
  }
};

const mapFieldsForDirectum = async (directumFields) => {

  const {
    counterparty,
    bankData,
    contact,
    requestBody,
    profile,
    tariffAndServices,
    opportunityId,
    contractData,
    preScoringOverdraft
  } = directumFields;

  const CounterpartyData = {
    name: counterparty.name,
    INN: counterparty.iNN,
    KPP: counterparty.kPP,
    legalAddress: counterparty.legalAddress,
    postalAddress: counterparty.postalAddress,
    phoneNumber: contact.phoneNumber,
    Email: contact.email,
    OGRN: counterparty.oGRN,
    OKVED: counterparty.okVED,
    OKPO: counterparty.oKPO,
    checkingAccount: bankData.checkingAccount
  };

  const counterpartySignatoryData = {
    fullName: counterparty.leaderFullName,
    email: '',
    phoneNumber: '',
    position: counterparty.leaderPosition
  };

  const contactData = {
    fullName: contact.fullName,
    email: contact.email,
    phoneNumber: contact.phoneNumber,
    position: contact.position
  };

  const counterpartyBankData = {
    name: bankData.bankName,
    bIC: bankData.bankBic,
    correspondentAccount: bankData.corBankAccount
  };

  requestBody.DocumentKind = contractData.categoryOfСontract;
  requestBody.BusinessUnit = contractData.organization;
  requestBody.Subject = CONTRACT_SUBJECT;
  requestBody.Counterparty = Object.values(CounterpartyData).join("|");
  requestBody.RequestID = opportunityId+Math.random().toString();
  requestBody.Note = contractData.contractNote;
  requestBody.TotalAmount = contractData.contractAmount;
  requestBody.pCurrency = CURRENCY_RUB;
  requestBody.CounterpartyBank = Object.values(counterpartyBankData).join("|");
  requestBody.CounterpartySignatory = Object.values(counterpartySignatoryData).join("|");
  requestBody.Contact = Object.values(contactData).join("|");
  requestBody.IsStandard = contractData.standardСontractSelected;
  requestBody.CardCountBK = tariffAndServices.cardsAmountBK;
  requestBody.CardCountTK = tariffAndServices.cardsAmountTK;
  requestBody.Rate = tariffAndServices.selectedTariff;
  requestBody.Promotion = tariffAndServices.selectedPromocode;
  requestBody.CodeWord = profile.codeWord;
  requestBody.CountOfVehicle = (counterparty.truckCount ? +counterparty.truckCount : 0) +
    (counterparty.carCount ? +counterparty.carCount : 0);
  requestBody.ForecastLiters = counterparty.litersPrediction;
  requestBody.Login = profile.email;
  requestBody.Credit = preScoringOverdraft;
  requestBody.PhoneNumber = profile.phoneNumber;
  requestBody.Email = profile.email;
  requestBody.Summ = contractData.amountPayment;
  requestBody.LKGK = profile.unificationLKGK;
}

export {
  mapSparkAddressIntoAddress,
  mapDadataSelectedValueIntoAddress,
  mapPrimaryContactBdData,
  mapAccountBdData,
  mapOpportunityBdData,
  mapCreditFactoryReportsBdData,
  mapFieldsForDirectum
};
