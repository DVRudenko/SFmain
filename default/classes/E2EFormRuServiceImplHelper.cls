public without sharing class E2EFormRuServiceImplHelper {
    public static final String DATE_FORMAT_PATTERN = 'dd-MMM-yyyy';
    public static final String EDM_RESOURCE_NAME = 'EDMNames';
    public static final String PERSONAL_OFFICE_DATA_EMPTY_ERROR = 'Error: personal office email OR personal office phone is empty.';

    //SF-1313 start
    /*******************************************************************************
     *  Name            : exculeObjectsFromList(List<sObject> sourceList, List<sObject> exclusionList)
     *  Summary         : e2e business, exclude opportunity linked account contacts from process
     *  CreatedDate     : 05/05/2020
     *  ModifiedDate    : -
     *  Parameters      : List<sObject> sourceList, List<sObject> exclusionList
     *  Returns         : List<sObject> - source list without excluded values
     ******************************************************************************/
    public static List<sObject> exculeObjectsFromList(List<sObject> sourceList, List<sObject> exclusionList) {
        if (sourceList != null && !sourceList.isEmpty() && exclusionList != null && !exclusionList.isEmpty()) {
            List<sObject> cleanedObjects = new List<sObject>();
            Map<Id, sObject> uniqueObjectForExcludeMap = new Map<Id, sObject>(exclusionList);
            for (sObject currentRecord : sourceList) {
                if (!uniqueObjectForExcludeMap.containsKey(currentRecord.Id)) {
                    cleanedObjects.add(currentRecord);
                }
            }
            return cleanedObjects;
        } else {
            return sourceList;
        }
    }
    //SF-1313 end

    // ********************* !!!КОСТЫЛИ!!! *************************** //
    //TODO: ПРИ ЛЮБОМ ИЗМЕНЕНИИ ЛОГИКИ РОССИЙСКОЙ ДЕДУБЛИКАЦИИ
    //TODO: НУЖНО ОБЯЗАТЕЛЬНО УБЕДИТЬСЯ ЧТО ЭТИ МЕТОДЫ (matchAdditionalEmails) НИЧЕГО НЕ ЛОМАЮТ В ИЗМЕНЕННОЙ ЛОГИКЕ
    //TODO: И ПРИ НЕОБХОДИМОСТИ ПОДКРУТИТЬ ИХ
    /*******************************************************************************
     *  Name            : matchAdditionalEmails(List<Contact> contacts, String email)
     *  Summary         : processes a full email match for Additional_Emails__c field in Contact
     *  CreatedDate     : 30/06/2020
     *  ModifiedDate    : -
     *  Parameters      : List<Contact> contacts - contacts to be matched, String email - email to be found
     *  Returns         : List<Contact> - contacts with full match by email
     ******************************************************************************/
    public static List<Contact> matchAdditionalEmails(List<Contact> contacts, String email) {
        List<Contact> matchedContacts = new List<Contact>();
        for (Contact contact : contacts) {
            if (contact.Email != null && contact.Email.equals(email)) {
                matchedContacts.add(contact);
            } else if (contact.Additional_Emails__c != null && email != null && contact.Additional_Emails__c.split(':').contains(email)) {
                matchedContacts.add(contact);
            }
        }
        return matchedContacts;
    }

    /*******************************************************************************
     *  Name            : matchAdditionalEmails(List<Contact> contacts, String email, String phone)
     *  Summary         : processes a full email match for Additional_Emails__c field in Contact
     *  CreatedDate     : 30/06/2020
     *  ModifiedDate    : -
     *  Parameters      : List<Contact> contacts - contacts to be matched, String email - email to be found, String phone - phone to be found
     *  Returns         : List<Contact> - contacts with full match by email
     ******************************************************************************/
    public static List<Contact> matchAdditionalEmails(List<Contact> contacts, String email, String phone) {
        List<Contact> matchedContacts = new List<Contact>();
        for (Contact contact : contacts) {
            if (contact.Email != null && contact.Email.equals(email)) {
                matchedContacts.add(contact);
            } else if (contact.Formatted_phones__c != null && phone != null && contact.Formatted_phones__c.contains(phone)) {
                matchedContacts.add(contact);
            } else if (contact.Formatted_phones_additional__c != null && phone != null && contact.Formatted_phones_additional__c.contains(phone)) {
                matchedContacts.add(contact);
            } else if (
                contact.Additional_Emails__c != null &&
                email != null &&
                contact.Additional_Emails__c.contains(email) &&
                contact.Additional_Emails__c.split(':').contains(email)
            ) {
                matchedContacts.add(contact);
            }
        }
        return matchedContacts;
    }

    /*******************************************************************************
     *  Name            : matchAdditionalEmails(List<Lead> leads, String email)
     *  Summary         : processes a full email match for Additional_Emails__c field in Lead
     *  CreatedDate     : 30/06/2020
     *  ModifiedDate    : -
     *  Parameters      : List<Lead> leads - leads to be matched, String email - email to be found
     *  Returns         : List<Lead> - leads with full match by email
     ******************************************************************************/
    public static List<Lead> matchAdditionalEmails(List<Lead> leads, String email) {
        List<Lead> matchedLeads = new List<Lead>();
        for (Lead lead : leads) {
            if (lead.Email != null && lead.Email.equals(email)) {
                matchedLeads.add(lead);
            } else if (lead.Additional_Emails__c != null && email != null && lead.Additional_Emails__c.split(':').contains(email)) {
                matchedLeads.add(lead);
            }
        }
        return matchedLeads;
    }

    /*******************************************************************************
     *  Name            : matchAdditionalEmails(List<Lead> leads, String email, String phone)
     *  Summary         : processes a full email match for Additional_Emails__c field in Lead
     *  CreatedDate     : 30/06/2020
     *  ModifiedDate    : -
     *  Parameters      : List<Lead> leads - leads to be matched, String email - email to be found, String phone - phone to be found
     *  Returns         : List<Lead> - leads with full match by email
     ******************************************************************************/
    public static List<Lead> matchAdditionalEmails(List<Lead> leads, String email, String phone) {
        List<Lead> matchedLeads = new List<Lead>();
        for (Lead lead : leads) {
            if (lead.Email != null && lead.Email.equals(email)) {
                matchedLeads.add(lead);
            } else if (lead.Formatted_phones__c != null && phone != null && lead.Formatted_phones__c.contains(phone)) {
                matchedLeads.add(lead);
            } else if (lead.Formatted_phones_additional__c != null && phone != null && lead.Formatted_phones_additional__c.contains(phone)) {
                matchedLeads.add(lead);
            } else if (lead.Additional_Emails__c != null && email != null && lead.Additional_Emails__c.split(':').contains(email)) {
                matchedLeads.add(lead);
            }
        }
        return matchedLeads;
    }

    /*******************************************************************************
     *  Name            : matchAdditionalEmails(List<Lead> leads, String email, String phone, String inn)
     *  Summary         : processes a full email match for Additional_Emails__c field in Lead
     *  CreatedDate     : 30/06/2020
     *  ModifiedDate    : -
     *  Parameters      : List<Lead> leads - leads to be matched, String email - email to be found,
     *                  : String phone - phone to be found, String inn - inn to be found
     *  Returns         : List<Lead> - leads with full match by email
     ******************************************************************************/
    public static List<Lead> matchAdditionalEmails(List<Lead> leads, String email, String phone, String inn) {
        List<Lead> matchedLeads = new List<Lead>();
        for (Lead lead : leads) {
            if (lead.Email != null && lead.Email.equals(email)) {
                matchedLeads.add(lead);
            } else if (lead.INN__c != null && lead.INN__c.equals(inn)) {
                matchedLeads.add(lead);
            } else if (lead.Formatted_phones__c != null && phone != null && lead.Formatted_phones__c.contains(phone)) {
                matchedLeads.add(lead);
            } else if (lead.Formatted_phones_additional__c != null && phone != null && lead.Formatted_phones_additional__c.contains(phone)) {
                matchedLeads.add(lead);
            } else if (
                lead.Additional_Emails__c != null &&
                email != null &&
                lead.Additional_Emails__c.contains(email) &&
                lead.Additional_Emails__c.split(':').contains(email)
            ) {
                matchedLeads.add(lead);
            }
        }
        return matchedLeads;
    }

    /*******************************************************************************
     *  Name            : generateEDMInfo(TransitRequestData transitRequestData, E2EFormParams formParams)
     *  Summary         : method generates edm(ЭДО) info
     *  CreatedDate     : 22/09/2020
     *  ModifiedDate    : -
     *  Parameters      : TransitRequestData transitRequestData - transit request record,
     *                  : E2EFormParams formParams - form params of process
     *  Returns         : inner class EDMInfo of TransitRequestData class
     ******************************************************************************/
    public static TransitRequestData.EDMInfo generateEDMInfo(TransitRequestData transitRequestData, E2EFormParams formParams) {
        TransitRequestData.EDMInfo edmInfo;
        if (transitRequestData != null && formParams != null && !String.isBlank(formParams.electronicDocumentManagement)) {
            List<StaticResource> edmSRList = [SELECT Body FROM StaticResource WHERE Name =: EDM_RESOURCE_NAME LIMIT 1];

            if (edmSRList != null && !edmSRList.isEmpty()) {
                Map<String, Object> resourceNames = (Map<String, Object>) ((Map<String, Object>) JSON.deserializeUntyped(
                    (edmSRList.get(0)).Body.toString()
                ));

                if (resourceNames.size() > 0 && resourceNames.containsKey(formParams.electronicDocumentManagement)) {
                    edmInfo = new TransitRequestData.EDMInfo();
                    edmInfo.electronicDocumentManagement = (String) resourceNames.get(formParams.electronicDocumentManagement);
                    edmInfo.docType = 1;
                    edmInfo.docSigned = 1;

                    if (transitRequestData != null && transitRequestData.cont != null) {
                        List<String> dateValues = transitRequestData.cont.contractDate.split('\\.');
                        Datetime dateTimeValue = Datetime.newInstance(
                            Date.newInstance(
                                Integer.valueOf(dateValues.get(2)),
                                Integer.valueOf(dateValues.get(1)),
                                Integer.valueOf(dateValues.get(0))
                            ),
                            Time.newInstance(0, 0, 0, 0)
                        );
                        edmInfo.signDate = dateTimeValue.format(DATE_FORMAT_PATTERN);
                    } else {
                        edmInfo.signDate = Datetime.now().format(DATE_FORMAT_PATTERN);
                    }
                }
            }
        }

        return edmInfo;
    }

    public Integer getContractTypeByPeriod(Decimal period) {
        if (period != null) {
            Map<Integer, Integer> contractTypeMapping = getContractTypeMapping();
            Integer convertedPeriod = Integer.valueOf(period);
            return contractTypeMapping.get(convertedPeriod);
        }

        return null;
    }

    @TestVisible
    private Map<Integer, Integer> getContractTypeMapping() {
        Map<Integer, Integer> contractTypeMapping = new Map<Integer, Integer>();

        List<Transit_Contract_Type_Mapping__c> transitContractTypeMappings = Transit_Contract_Type_Mapping__c.getall().values();
        for (Transit_Contract_Type_Mapping__c transitContractTypeMapping : transitContractTypeMappings) {
            contractTypeMapping.put(Integer.valueOf(transitContractTypeMapping.Credit_Period__c), Integer.valueOf(transitContractTypeMapping.Contract_Type__c));
        }

        return contractTypeMapping;
    }

    public String getCreditPeriodInWords(Decimal creditperiod) {
        if (creditperiod == null) {
            return '';
        }

        List<Transit_Contract_Type_Mapping__c> transitContractTypeMappings = Transit_Contract_Type_Mapping__c.getall().values();
        if (!transitContractTypeMappings.isEmpty()) {
            for (Transit_Contract_Type_Mapping__c transitContractTypeMapping : transitContractTypeMappings) {
                Boolean valuesIsExist = transitContractTypeMapping.Credit_Period__c != null && String.isNotBlank(transitContractTypeMapping.Credit_Period_In_Words__c);
                if (valuesIsExist && transitContractTypeMapping.Credit_Period__c == creditperiod) {
                    return transitContractTypeMapping.Credit_Period_In_Words__c;
                }
            }  
        }

        return '';
    }

    /*******************************************************************************
     *  Name            : checkingOwnerForOpportunities(List<Opportunity> listOpportunity, E2EFormRuDeduplicationResult deduplicationResult)
     *  Summary         : e2e business, checking that all opportunities are with the same owner
     *  CreatedDate     : 24/02/2021
     *  ModifiedDate    : -
     *  Parameters      : List<Opportunity> listOpportunity, E2EFormRuDeduplicationResult deduplicationResult
     *  Returns         : -
     ******************************************************************************/
    public static void checkingOwnerForOpportunities(List<Opportunity> foundOpportunities, E2EFormRuDeduplicationResult deduplicationResult) {
        Opportunity e2eOpportunity = deduplicationResult.e2eOpportunity;
        deduplicationResult.isDifferentOwnerFoundForOpportunities = false;
        for (Opportunity opportunity : foundOpportunities) {
            if (opportunity.OwnerId != e2eOpportunity.OwnerId) {
                deduplicationResult.isDifferentOwnerFoundForOpportunities = true;
                break;
            }
        }
    }

    public void addPersonalOfficeData(ReportRequestData requestData, E2EFormParams formParams) {
        if (requestData != null && requestData.reportParams != null && formParams != null) {
            if (String.isBlank(formParams.emailForPersonalOffice) || String.isBlank(formParams.personalOfficePhone)) {
                throw new E2EFormRuException(PERSONAL_OFFICE_DATA_EMPTY_ERROR);
            }
            requestData.reportParams.PERSONAL_OFFICE_EMAIL = formParams.emailForPersonalOffice;
            requestData.reportParams.PERSONAL_OFFICE_PHONE = formParams.personalOfficePhone;
        }
    }
}
