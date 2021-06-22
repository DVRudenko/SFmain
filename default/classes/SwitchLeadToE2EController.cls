public class SwitchLeadToE2EController {
    public Boolean isError {get; set;}

    public SwitchLeadToE2EController() {}

    public PageReference init() {
        try {
            this.isError = false;
            String leadId;
            Map<String, String> parametersMap = ApexPages.currentPage().getParameters();

            if (ApexPages.CurrentPage().getparameters().get('lid') != null) {
                leadId = ApexPages.CurrentPage().getparameters().get('lid');
            } else if (ApexPages.CurrentPage().getparameters().get('eid') != null) {
                String decryptParams = doDecryptParams(ApexPages.CurrentPage().getparameters().get('eid'));
                if (decryptParams != null) {
                    leadId = decryptParams.substringBefore('-');
                }
            }
            if (leadId == null) {
                return new PageReference(ETEGlobalUtils.returnSiteUrl(null));
            }

            List<Lead> leadsList = [
                    SELECT Owner.Name, IsConverted, ConvertedOpportunity.E2E_Encoded_URL__c, Country, Anzahl_der_Fahrzeuge__c, Channel__c, Salutation, RecordType.Name, Status,
                            LeadSource, CCS_number_of_cards__c, Email, CountryCode, Number_of_Cards_facebook__c, Sec_Channel__c, E2E_Assistant__c, E2E_Manual_Adoption_Date__c, Partner_OBN__c,
                            Utm_campaign__c, Agree_to_receive_comm_info_by_email__c, FirstName, LastName, Phone, Company, Owner.Type, Agree_to_process_pers_data_for_marketing__c,
                            Agree_to_telephone_contact__c
                    FROM Lead
                    WHERE Id = :leadId AND
                          Country != NULL
                    LIMIT 1];

            if (leadsList.isEmpty()) {
                return new PageReference(ETEGlobalUtils.returnSiteUrl(null));
            }

            String countryCode = leadsList.get(0).CountryCode.toLowerCase();
            String implKey = leadsList.get(0).Country;
            if (leadsList.get(0).Country == 'Poland' && leadsList.get(0).RecordType.Name == 'Lotos') {
                implKey = implKey + ' ' + leadsList.get(0).RecordType.Name;
            }

            String urlPath = ETEGlobalUtils.returnUrlPath(implKey).getUrl();

            if ( ! leadsList.isEmpty() && leadsList.get(0).IsConverted && leadsList.get(0).ConvertedOpportunity.E2E_Encoded_URL__c != null) {
                return new PageReference(urlPath + '?source=' + leadsList.get(0).ConvertedOpportunity.E2E_Encoded_URL__c);
            } else if ( ! leadsList.isEmpty() && leadsList.get(0).IsConverted && leadsList.get(0).ConvertedOpportunity.E2E_Encoded_URL__c == null) {
                return new PageReference(urlPath);
            }

            Lead currentLead = leadsList.get(0);

            if (GlobalUtils.isSwitchToE2EFromFacebook(currentLead) || GlobalUtils.isSwitchToE2EInboundCall(currentLead) || GlobalUtils.isSwitchToE2EInboundEmail(currentLead) ||
                    GlobalUtils.isSwitchToE2EShellEmail(currentLead) || GlobalUtils.isSwitchToE2EFromPopup(currentLead) || GlobalUtils.isSwitchToE2EFromShortForm(currentLead) ||
                    GlobalUtils.isSwitchToE2EFromPartnerJITB(currentLead) || GlobalUtils.isSwitchToE2ETabletShortForm(currentLead) || GlobalUtils.isSwitchToE2EManualAdoption(currentLead) ||
                    (GlobalUtils.isAdoptionProcessLotos(currentLead) && currentLead.RecordType.Name == 'Lotos') ||
                    (GlobalUtils.isAdoptionProcessShell(currentLead) && currentLead.RecordType.Name == 'Endkunde') ||
                    GlobalUtils.isE2EAdoptionHU(currentLead)) {
                if (currentLead.CCS_number_of_cards__c == null) {
                    if (currentLead.Number_of_Cards_facebook__c != null) {
                        currentLead.CCS_number_of_cards__c = Integer.valueOf(currentLead.Number_of_Cards_facebook__c);
                    } else if (currentLead.Anzahl_der_Fahrzeuge__c != null) {
                        currentLead.CCS_number_of_cards__c = Integer.valueOf(currentLead.Anzahl_der_Fahrzeuge__c);
                    }
                }

                E2E_Data_Object__c dataObject;
                List<E2E_Data_Object__c> dataObjectToCheck = [SELECT Id FROM E2E_Data_Object__c WHERE Lead__c = :leadId];

                if (dataObjectToCheck.isEmpty()) {
                    ETEDatabaseInterface e2eDatabase = ETEGlobalUtils.getDatabaseConnector(countryCode);
                    ETEStepInterface e2eStep = ETEGlobalUtils.getETEStepImplementation(implKey);
                    Map<String, Object> untypedSettings = e2eDatabase.getSettings(implKey, countryCode);
                    List<String> availableStepsList = e2eStep.getAvailableSteps(untypedSettings, null);
                    ETEBusinessObjectsInterface businessObjectsHandler = ETEGlobalUtils.getETEBusinessObjectsHandler(implKey);
                    String shortCompanyName = leadsList.get(0).Company;
                    if (shortCompanyName.length() > 25) {
                        shortCompanyName = shortCompanyName.substring(0, 25);
                    }
                    dataObject = businessObjectsHandler.initDataObject(availableStepsList, countryCode, implKey);
                    dataObject.Name = leadsList.get(0).Company;
                    dataObject.Lead__c = leadsList.get(0).Id;
                    dataObject.Company_Short_Name__c = shortCompanyName;
                    dataObject.Agree_to_process_pers_data_for_marketing__c = leadsList.get(0).Agree_to_process_pers_data_for_marketing__c;
                    dataObject.Agreement_To_Receive_Info_By_Email__c = leadsList.get(0).Agree_to_receive_comm_info_by_email__c;
                    dataObject.Agreement_To_Phone_Contact__c = leadsList.get(0).Agree_to_telephone_contact__c;

                    if ( ! parametersMap.isEmpty() ) {
                        for (String key : parametersMap.keySet()) {
                            key = key.toLowerCase();
                            if (key == 'utm_campaign') {
                                dataObject.Utm_Campaign__c = parametersMap.get(key);
                            } else if (key == 'utm_content') {
                                dataObject.Utm_Content__c = parametersMap.get(key);
                            } else if (key == 'utm_medium') {
                                dataObject.Utm_Medium__c = parametersMap.get(key);
                            } else if (key == 'utm_placement') {
                                dataObject.Utm_Placement__c = parametersMap.get(key);
                            } else if (key == 'utm_source') {
                                dataObject.Utm_Source__c = parametersMap.get(key);
                            } else if (key == 'utm_term') {
                                dataObject.Utm_Term__c = parametersMap.get(key);
                            } else if (key == 'utm_url') {
                                dataObject.Utm_Url__c = parametersMap.get(key);
                            } else if (key == 'utm_products') {
                                dataObject.Utm_Products__c = parametersMap.get(key);
                            }
                        }
                    }

                    insert dataObject;

                    E2E_Data_Contact__c dataContact = new E2E_Data_Contact__c(
                            E2E_Data_Object__c = dataObject.Id,
                            First_Name__c = leadsList.get(0).FirstName,
                            Last_Name__c = leadsList.get(0).LastName,
                            Email__c = leadsList.get(0).Email,
                            Phone__c = leadsList.get(0).Phone,
                            Salutation__c = 'Mr.',
                            Role__c = 'Decision Maker',
                            isPrimary__c = true,
                            Index__c = 0
                    );
                    insert dataContact;

                    // insert data log to run checkBusinessObjects after redirect
                    List<RecordType> e2eDataLogRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'E2E_Data_Log__c' AND DeveloperName = 'Job_Status' LIMIT 1];
                    E2E_Data_Log__c dataLog = new E2E_Data_Log__c(
                            E2E_Data_Object__c = dataObject.Id,
                            Job_Status__c = 'Completed',
                            Name = 'checkBusinessObjects'
                    );
                    if ( ! e2eDataLogRecordTypeList.isEmpty() ) {
                        dataLog.RecordTypeId = e2eDataLogRecordTypeList.get(0).Id;
                    }
                    insert dataLog;

                    if (currentLead.Salutation == null || currentLead.Salutation == '' || currentLead.Owner.Type != 'User') {
                        E2E_Form_General_Settings__c e2eGeneralSettings = E2E_Form_General_Settings__c.getInstance(currentLead.Country);
                        currentLead.OwnerId = e2eGeneralSettings.Integration_Admin_Id__c;
                        currentLead.Salutation = 'Mr.';

                        update currentLead;
                    }

                    List<String> jobsNeededToRun = new List<String>{'checkBusinessObjects'};
                    ETEJobChainHandler jobChainHandler = new ETEJobChainHandler(jobsNeededToRun, dataObject.Id, countryCode, implKey);
                    jobChainHandler.runNext();
                } else {
                    dataObject = dataObjectToCheck.get(0);
                }
                String source = ETEGlobalUtils.doEncryptParams(dataObject.Id, countryCode);

                return new PageReference(urlPath + '?source=' + source);
            } else {
                return new PageReference(urlPath);
            }
        } catch (Exception e) {
            ExceptionLogger.sendException(String.valueOf('Lead Switch to E2E Exception: ' + e.getMessage()), String.valueOf(e.getStackTraceString()));
            this.isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Internal error'));
            return null;
        }
    }


    private String doDecryptParams(String encryptedParams) {
        encryptedParams = encryptedParams.replaceAll('(\\s|%2B)', '+');
        Blob key = EncodingUtil.base64Decode(E2EKeysAPI__c.getValues('E2EForm').AES256_Key__c);
        Blob dest = EncodingUtil.base64Decode(encryptedParams);
        Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
        String decryptedParams = decrypted.toString();
        return decryptedParams;
    }
}