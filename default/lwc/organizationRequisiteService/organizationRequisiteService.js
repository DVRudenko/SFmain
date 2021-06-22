import { updateRecord, createRecord } from "lightning/uiRecordApi";
import insertOppContactRole from "@salesforce/apex/OrganizationRequisiteDataService.insertOppContactRole";
import getPickListCreditFactoryReport from "@salesforce/apex/CFServiceLightning.getPickListCreditFactoryReport";
import {
  mapCreditFactoryFields,
  mapSparkDataFields
} from "c/mappingFromDtoToOjbectService";

const getSfPrimaryContact = (sfContactRoles) => {
  for (let sfContactRole of sfContactRoles) {
    if (sfContactRole.IsPrimary) {
      return sfContactRole.Contact;
    }
  }
  return null;
};

const getSfLeaderContacts = (sfContactRoles) => {
  let contacts = [];
  for (let sfContactRole of sfContactRoles) {
    if (!sfContactRole.IsPrimary) {
      contacts.push(sfContactRole.Contact);
    }
  }
  return contacts;
};

const getContactAfterInsert = (contact) => {
  let newContact = {
    Id: contact.id,
    LastName: contact.fields.LastName.value,
    FirstName: contact.fields.FirstName.value,
    MiddleName: contact.fields.MiddleName.value
  };
  return newContact;
};

const insertContactWithRole = (contact, isPrimary, opportunityId) => {
  return new Promise(function (resolve, reject) {
    let contactWithRole = {};
    createRecord(contact)
      .then((sfContact) => {
        contactWithRole["contact"] = sfContact;
        insertOppContactRole({
          isPrimary: isPrimary,
          contactId: sfContact.id,
          opportunityId: opportunityId
        })
          .then((cntRole) => {
            contactWithRole["cntRole"] = cntRole;
            resolve(contactWithRole);
          })
          .catch((err) => {
            reject(err);
          });
      })
      .catch((err) => {
        reject(err);
      });
  });
};

const upsertContact = (contact, isPrimary, opportunityId) => {
  return new Promise(function (resolve, reject) {
    if (contact.fields.hasOwnProperty("Id")) {
      updateRecord(contact)
        .then((sfContact) => {
          resolve(sfContact);
        })
        .catch((err) => {
          reject(err);
        });
    } else {
      insertContactWithRole(contact, isPrimary, opportunityId)
        .then((sfContact) => {
          resolve(sfContact);
        })
        .catch((err) => {
          reject(err);
        });
    }
  });
};

const processContactsUpdation = (primaryCont, leaderContact, opportunityId) => {
  return new Promise(function (resolve, reject) {
    let insertedContacts = {};
    upsertContact(primaryCont, true, opportunityId)
      .then((cntData) => {
        if (cntData.cntRole != null) {
          insertedContacts["primaryContact"] = getContactAfterInsert(
            cntData.contact
          );
        }
        if (leaderContact != null) {
          upsertContact(leaderContact, false, opportunityId)
            .then((cntData) => {
              if (cntData.cntRole != null) {
                insertedContacts["leaderContact"] = getContactAfterInsert(
                  cntData.contact
                );
              }
              resolve(insertedContacts);
            })
            .catch((err) => {
              reject(err);
            });
        } else {
          resolve(insertedContacts);
        }
      })
      .catch((err) => {
        reject(err);
      });
  });
};

const updateSfData = (data) => {
  return new Promise(function (resolve, reject) {
    updateRecord(data.opportunity)
      .then(() => {
        updateRecord(data.account)
          .then(() => {
            processContactsUpdation(
              data.primaryContact,
              data.leaderContact,
              data.opportunity.fields.Id
            )
              .then((cntData) => {
                resolve(cntData);
              })
              .catch((err) => {
                reject(err);
              });
          })
          .catch((err) => {
            reject(err);
          });
      })
      .catch((err) => {
        reject(err);
      });
  });
};

const getPickListCreditFactoryReportData = async (scoringDesign) => {
  let mapData = new Map();
  let scoringData;
  await getPickListCreditFactoryReport({})
    .then(result => {
      for (const key in result) {
        mapData.set(key, result[key]);
      }
      [...mapData.entries()]
        .filter(item => {
          if (item[1] == scoringDesign) {
            scoringData = item[0];
            return;
          }
        });
    });
  return scoringData;
};

const updateSparkDataFields = (
  sparkData,
  accountId,
  opportunityId,
  blackListData,
  leaderContacts,
  litersPrediction
) => {
  let fields = mapSparkDataFields(
    sparkData,
    accountId,
    opportunityId,
    blackListData,
    leaderContacts,
    litersPrediction
  );

  if (litersPrediction != null) {
    return new Promise((resolve, reject) => {
      updateRecord({ fields })
        .then(() => {
          updateRecord({ fields: fields.oppFields })
            .then(() => {
              upsertContact(fields.recordInput, false, opportunityId)
                .then(contact => {
                  if (contact.cntRole != null) {
                    getContactAfterInsert(contact.contact);
                  }
                  resolve(contact);
                })
                .catch((err) => {
                  reject(err);
                });
            })
            .catch((err) => {
              reject(err);
            });
        })
        .catch((err) => {
          reject(err);
        });
    });
  } else {
    updateRecord({ fields });
  }
};

const upsertCreditFactoryFields = async (
  preScoringData,
  opportunityId,
  accountId,
  russianCreditCheckRecordTypeId,
  prescoring,
  creditFactoryId
) => {
  const scoringDecision = await getPickListCreditFactoryReportData(preScoringData.decisionString);
  const fields = mapCreditFactoryFields(
    preScoringData,
    opportunityId,
    accountId,
    russianCreditCheckRecordTypeId,
    prescoring,
    creditFactoryId,
    scoringDecision
  );

  if (creditFactoryId != null) {
    updateRecord({ fields });
  } else {
    createRecord(fields);
  }
};

export {
  updateSfData,
  processContactsUpdation,
  upsertContact,
  getSfPrimaryContact,
  getSfLeaderContacts,
  getContactAfterInsert,
  insertContactWithRole,
  updateSparkDataFields,
  upsertCreditFactoryFields
};