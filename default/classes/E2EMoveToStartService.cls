public with sharing class E2EMoveToStartService {
    private static final String SENT_TO_RMD = System.Label.SentToRMD;
    private static final String RMD_APPROVAL_SIDE = System.Label.RMDApprovalSide;
    private static final String SENDING_TO_RMD_FAILED = System.Label.SendingToRMDFailed;
    private static final String APPROVED = 'Approved';
    private static final String SENDING_TO_SERVICE = System.Label.SendToService;
    private static final String SENDING_TO_SERVICE_FAILED = System.Label.SendToServiceFailed;
    private static final String SENDING_TO_ADMIN = System.Label.SendToAdmin;
    private static final String SENDING_TO_ADMIN_FAILED = System.Label.SendToAdminFailed;
    private static final String RUSSIAN_CONTACT_RECORD_TYPE_ID = GlobalUtils.getRecordTypeId('Contact', 'Russian');
    private static final Integer ADDITIONAL_PHONES_MAX_LENGTH = Contact.Additional_Phones__c.getDescribe().getLength();
    private static final Integer ADDITIONAL_EMAILS_MAX_LENGTH = Contact.Additional_Emails__c.getDescribe().getLength();
    private static final String DEFAULT_CONT_SALUTATION = 'Mr.';

    public static final String TARIF_PART_2020 = '2020';
    public static final String SHELL_SITE_PETROL = 'Шелл Сайт_АИ';
    public static final String SHELL_SITE_DF = 'Шелл Сайт_ДТ';
    public static final String FREE_OVERDRAFT = E2EFormData__c.Free_overdraft__c.getDescribe().getLabel();
    public static final String WITHOUT_CREDIT = System.Label.without_credit;

    private E2E_business_settings__c e2eBusinessSetting = E2E_business_settings__c.getValues(GlobalUtils.FleetcorCountries.Russia.name());

    // RMD - Risk Management Department(ОУР)
    public boolean checkForRMDApproval(CompanyVerificationScoring verificationDecision, Id opportunityId, E2E_business_settings__c setting) {
        Boolean terminateprocess = false;
        Boolean decisionNotNull = verificationDecision != null && verificationDecision.decision != null;
        Boolean decisionSatisfied = decisionNotNull && (verificationDecision.decision == 1 || verificationDecision.decision == 4);
        Boolean approvalNameExist = setting != null && String.isNotBlank(setting.Approval_Process_Name__c);
        Boolean recordLocked = checkRMDRecordLock(opportunityId);

        if (decisionSatisfied && approvalNameExist && opportunityId != null && !recordLocked) {
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setObjectId(opportunityId);
            approvalRequest.setProcessDefinitionNameOrId(setting.Approval_Process_Name__c);
            approvalRequest.setSkipEntryCriteria(true);

            try {
                Approval.process(approvalRequest);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, SENT_TO_RMD));
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SENDING_TO_RMD_FAILED));
                String notificationMessage =
                    '<br/>E2E Business. Мethod checkForRMDApproval: opportunityId = ' +
                    opportunityId +
                    '. Message: ' +
                    String.valueOf(ex.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(ex.getStackTraceString()));
            } finally {
                terminateprocess = true;
            }
        } else if (recordLocked) {
            terminateprocess = true;
        }

        return terminateprocess;
    }

    public boolean checkRMDRecordLock(Id opportunityId) {
        if (opportunityId == null) {
            return false;
        }

        Boolean recordIsLocked = Approval.isLocked(opportunityId);
        if (recordIsLocked) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, RMD_APPROVAL_SIDE));
        }

        return recordIsLocked;
    }

    public Boolean checkStartAvailability(E2E_business_settings__c setting, Boolean recordLockecdByRMD) {
        Boolean startButtonEnabled = true;

        // first expression of higher priority, second can't influence
        if (setting != null && setting.Block_start_button__c) {
            startButtonEnabled = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.E2E_business_start_blocked));
        } else if (recordLockecdByRMD != null && recordLockecdByRMD) {
            startButtonEnabled = false;
        }

        return startButtonEnabled;
    }

    public Boolean checkRMDDecision(CompanyVerificationScoring verificationDecision, Id opportunityId, E2E_business_settings__c setting) {
        Boolean opportunityApprooved = false;
        Boolean decisionNotNull = verificationDecision != null && verificationDecision.decision != null;
        Boolean decisionSatisfied = decisionNotNull && (verificationDecision.decision == 1 || verificationDecision.decision == 4);
        Boolean approvalNameExist = setting != null && String.isNotBlank(setting.Approval_Process_Name__c);

        if (decisionSatisfied && approvalNameExist && opportunityId != null) {
            List<ProcessInstance> processInstance = [SELECT Status FROM ProcessInstance WHERE TargetObjectId = :opportunityId];

            if (!processInstance.isEmpty() && processInstance.get(0).Status == APPROVED) {
                opportunityApprooved = true;
            }
        }

        return opportunityApprooved;
    }

    public static void sendApprovalToService(id opportunityId, E2E_business_settings__c setting) {
        System.debug('--->>> sendApprovalToService');
        Boolean approvalNameIsNotNull = setting != null && String.isNotBlank(setting.Approval_Process_Service_Name__c);
        Approval.ProcessSubmitRequest approvalRequestForService = new Approval.ProcessSubmitRequest();
        if (approvalNameIsNotNull && opportunityId != null) {
            approvalRequestForService.setObjectId(opportunityId);
            approvalRequestForService.setProcessDefinitionNameOrId(setting.Approval_Process_Service_Name__c);
            approvalRequestForService.setSkipEntryCriteria(true);
            try {
                Approval.process(approvalRequestForService);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, SENDING_TO_SERVICE));
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SENDING_TO_SERVICE_FAILED));
                String notificationMessage =
                    '<br/>E2E Business. Мethod sendApprovalToService: opportunityId = ' +
                    opportunityId +
                    '. Message: ' +
                    String.valueOf(ex.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(ex.getStackTraceString()));
            }
        }
    }
    public static void sendApprovalToAdmin(id opportunityId, E2E_business_settings__c setting) {
        System.debug('--->>> sendApprovalToAdmin');
        Boolean approvalNameIsNotNull = setting != null && String.isNotBlank(setting.Approval_Process_Admin_Name__c);
        Approval.ProcessSubmitRequest approvalRequestForService = new Approval.ProcessSubmitRequest();
        if (approvalNameIsNotNull && opportunityId != null) {
            approvalRequestForService.setObjectId(opportunityId);
            approvalRequestForService.setProcessDefinitionNameOrId(setting.Approval_Process_Admin_Name__c);
            approvalRequestForService.setSkipEntryCriteria(true);
            try {
                Approval.process(approvalRequestForService);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, SENDING_TO_ADMIN));
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, SENDING_TO_ADMIN_FAILED));
                String notificationMessage =
                    '<br/>E2E Business. Мethod sendApprovalToAdmin: opportunityId = ' +
                    opportunityId +
                    '. Message: ' +
                    String.valueOf(ex.getMessage());
                ExceptionLogger.sendException(notificationMessage, String.valueOf(ex.getStackTraceString()));
            }
        }
    }

    public Boolean checkApprovalStatus(Id Opportunity, E2E_business_settings__c setting) {
        Boolean ApprovalStatus = false;
        Boolean approvalSetting =
            setting != null &&
            (String.isNotBlank(setting.Approval_Process_Admin_Name__c) || String.isNotBlank(setting.Approval_Process_Service_Name__c));
        if (approvalSetting && Opportunity != null) {
            List<ProcessInstance> processInstance = [
                SELECT ProcessDefinition.Name
                FROM ProcessInstance
                WHERE Status = 'APPROVED' AND TargetObjectId = :Opportunity
            ];

            if (!processInstance.isEmpty()) {
                for (processInstance instancepr : processInstance) {
                    if (
                        (instancepr.ProcessDefinition.Name == setting.Approval_Process_Admin_Name__c) ||
                        instancepr.ProcessDefinition.Name == setting.Approval_Process_Service_Name__c
                    ) {
                        ApprovalStatus = true;
                    }
                }
            }
        }
        System.debug('ApprovalStatus ---->>> ' + ApprovalStatus);
        return ApprovalStatus;
    }

    // TODO: delete filter. Deactivate not used values in the picklist Product_PPR__c.
    public List<SelectOption> filterProducts(List<SelectOption> productOptions) {
        List<SelectOption> filteredProducts = new List<SelectOption>();
        List<String> allowedNames = new List<String>{ TARIF_PART_2020, SHELL_SITE_PETROL, SHELL_SITE_DF };

        if (productOptions != null && !productOptions.isEmpty()) {
            for (SelectOption productOption : productOptions) {
                String productName = productOption.getValue();

                for (String allowedName : allowedNames) {
                    if (productName.contains(allowedName)) {
                        filteredProducts.add(productOption);
                        break;
                    }
                }
            }
        }

        return filteredProducts;
    }

    public List<SelectOption> setCreditDecisions(List<Credit_Factory_Report__c> actualCfrs, E2EFormData__c formData, String ppSource) {
        List<SelectOption> creditDecisionList = new List<SelectOption>();
        List<String> fieldLabels = new List<String>{ WITHOUT_CREDIT };

        if (freeOverdraftAccessible(formData, ppSource)) {
            fieldLabels.add(FREE_OVERDRAFT);
        }

        if (fieldLabels != null && !fieldLabels.isEmpty()) {
            for (String fieldLabel : fieldLabels) {
                creditDecisionList.add(new SelectOption(fieldLabel, fieldLabel));
            }
        }

        if (actualCfrs != null) {
            for (Credit_Factory_Report__c actualCfr : actualCfrs) {
                creditDecisionList.add(new SelectOption(actualCfr.Id, actualCfr.Name));
            }
        }

        return creditDecisionList;
    }

    public void setPreselectedCreditDecision(List<Credit_Factory_Report__c> actualCfrs, E2EFormData__c formData, E2EFormParams formParams) {
        if (formParams == null) {
            return;
        }

        if (actualCfrs != null) {
            for (Credit_Factory_Report__c actualCfr : actualCfrs) {
                if (actualCfr.RU_Client_Choice__c) {
                    formParams.creditDecision = String.valueOf(actualCfr.Id);
                    break;
                }
            }
        }

        if (String.isBlank(formParams.creditDecision)) {
            if (formData != null && formdata.Free_overdraft__c != null && formdata.Free_overdraft__c) {
                formParams.creditDecision = FREE_OVERDRAFT;
            } else {
                formParams.creditDecision = WITHOUT_CREDIT;
            }
        }
    }

    public static string processContactUpsertion(E2EFormParams formParams, Opportunity oppty, String accountId) {
        ContactTriggerHandler.disableContactRolesInsertion = true;
        OpportunityContactRole sameContactWithRole;
        OpportunityContactRole oldMainContactWithRole;

        Contact contactFromForm = new Contact();
        List<String> contactNameParts = RussianUtils.parseContactNameByWhitespaces(formParams.contactFullName, 2);
        contactFromForm.LastName = contactNameParts[0];
        contactFromForm.FirstName = contactNameParts.size() > 1 ? contactNameParts[1] : '';
        contactFromForm.Phone = formParams.mainContactPhone;
        contactFromForm.Email = formParams.mainContactEmail;

        List<Contact> oldAndMainContacts = new List<Contact>();

        OpportunityContactRole newOppContRole = new OpportunityContactRole();
        OpportunityContactRole oldOppContRole = new OpportunityContactRole();
        if (!oppty.OpportunityContactRoles.isEmpty()) {
            for (OpportunityContactRole role : oppty.OpportunityContactRoles) {
                if (role.IsPrimary == true) {
                    oldMainContactWithRole = role;
                }
                String fullName = RussianUtils.mergeContactFullNameInRussianFormat(role.Contact.LastName, role.Contact.FirstName, null);
                if (fullName == formParams.contactFullName) {
                    sameContactWithRole = role;
                }
            }
        }

        if (sameContactWithRole != null) {
            oldAndMainContacts.add(sameContactWithRole.Contact);
            contactFromForm.Id = sameContactWithRole.Contact.Id;
            contactFromForm.Additional_Emails__c = sameContactWithRole.Contact.Additional_Emails__c;
            contactFromForm.Additional_Phones__c = sameContactWithRole.Contact.Additional_Phones__c;
            newOppContRole.Id = sameContactWithRole.Id;
        } else {
            contactFromForm.RecordTypeId = RUSSIAN_CONTACT_RECORD_TYPE_ID;
            contactFromForm.Salutation = DEFAULT_CONT_SALUTATION;
            contactFromForm.AccountId = accountId;
            newOppContRole.OpportunityId = oppty.Id;
        }

        if (oldMainContactWithRole != null) {
            if (oldMainContactWithRole == sameContactWithRole) {
                newOppContRole = null;
                oldOppContRole = null;
            } else {
                oldAndMainContacts.add(oldMainContactWithRole.Contact);
                oldOppContRole.Id = oldMainContactWithRole.Id;
            }
        } else {
            oldOppContRole = null;
        }

        updateAdditionalInfoValues(oldAndMainContacts, formParams, contactFromForm);
        upsert contactFromForm;
        String contactId = contactFromForm.Id;
        processRolesUpsertion(oldOppContRole, newOppContRole, contactId);
        ContactTriggerHandler.disableContactRolesInsertion = false;
        return contactId;
    }

    public static String addValueToAdditionalFieldOnMainFieldChange(
        String additionalFieldValue,
        String currentMainFieldValue,
        String oldMainFieldValue,
        String separator,
        Integer maxAdditionalFieldLength
    ) {
        if (oldMainFieldValue != currentMainFieldValue) {
            additionalFieldValue = addValueToMultivaluedLimitedField(additionalFieldValue, oldMainFieldValue, separator, maxAdditionalFieldLength);
            additionalFieldValue = removeSameValueFromMultivaluedField(additionalFieldValue, separator, currentMainFieldValue);
        }
        return additionalFieldValue;
    }

    private static String addValueToMultivaluedLimitedField(
        String multivaluedField,
        String value,
        String separator,
        Integer maxMultivaluedFieldLength
    ) {
        List<String> splitedMultivaluedField = new List<String>();
        if (!String.isBlank(multivaluedField)) {
            splitedMultivaluedField = multivaluedField.split(separator);
            if (!splitedMultivaluedField.contains(value)) {
                splitedMultivaluedField.add(0, value);
            }
        } else {
            splitedMultivaluedField.add(value);
        }
        String updatedMulivaluedField = String.join(splitedMultivaluedField, separator);
        while (updatedMulivaluedField.length() > maxMultivaluedFieldLength) {
            splitedMultivaluedField.remove(splitedMultivaluedField.size() - 1);
            updatedMulivaluedField = String.join(splitedMultivaluedField, separator);
        }
        return updatedMulivaluedField;
    }

    private static String removeSameValueFromMultivaluedField(String multivaluedField, String separator, String value) {
        List<String> splitedMultivaluedField = multivaluedField.split(separator);
        Integer index = splitedMultivaluedField.indexOf(value);
        if (index != -1) {
            splitedMultivaluedField.remove(index);
        }
        String updatedMultivaluedField = String.join(splitedMultivaluedField, separator);
        return updatedMultivaluedField;
    }

    private static void updateAdditionalInfoValues(List<Contact> oldAndMainContacts, E2EFormParams formParams, Contact contactFromForm) {
        if (!oldAndMainContacts.isEmpty()) {
            String additionalPhones = contactFromForm.Additional_Phones__c;
            String additionalEmails = contactFromForm.Additional_Emails__c;
            for (Contact contact : oldAndMainContacts) {
                additionalEmails = addValueToAdditionalFieldOnMainFieldChange(
                    additionalEmails,
                    formParams.mainContactEmail,
                    contact.Email,
                    ';',
                    ADDITIONAL_EMAILS_MAX_LENGTH
                );
            }
            additionalPhones = addValueToAdditionalFieldOnMainFieldChange(
                additionalPhones,
                formParams.mainContactPhone,
                oldAndMainContacts[0].Phone,
                ';',
                ADDITIONAL_PHONES_MAX_LENGTH
            );
            contactFromForm.Additional_Phones__c = additionalPhones;
            contactFromForm.Additional_Emails__c = additionalEmails;
        }
    }

    private static void processRolesUpsertion(OpportunityContactRole oldRole, OpportunityContactRole newRole, String contactId) {
        List<OpportunityContactRole> oppContactRolesForUpsert = new List<OpportunityContactRole>();

        if (newRole != null) {
            newRole.ContactId = ContactId;
            newRole.IsPrimary = true;
            oppContactRolesForUpsert.add(newRole);
        }

        if (oldRole != null) {
            oldRole.IsPrimary = false;
            oppContactRolesForUpsert.add(oldRole);
        }
        if (!oppContactRolesForUpsert.isEmpty()) {
            upsert oppContactRolesForUpsert;
        }
    }

    private Integer calculateCompanyAgeInMonths(E2EFormData__c formData) {
        if (formData != null && String.isNotBlank(formData.E2E_Reg_Date__c)) {
            Date registrationDate = CFUtils.parsePrescoringDate(formData.E2E_Reg_Date__c);
            return registrationDate.monthsBetween(Date.today());
        }

        return -1;
    }

    private boolean freeOverdraftAccessible(E2EFormData__c formData, String ppSource) {
        List<E2EBusiness_Free_Overdraft_Permission__c> freeOverdraftPermissions = E2EBusiness_Free_Overdraft_Permission__c.getAll().values();
        Boolean accessibleBySecurity = false;
        Boolean isPPSourceForFreeOverdraft = false;

        if (!freeOverdraftPermissions.isEmpty()) {
            Profile userProfile = ProfileManager.getUserProfileById(UserInfo.getProfileId());
            UserRole userRole = UserRoleManager.getUserRoleById(UserInfo.getUserRoleId());

            String profileName = (userProfile == null) ? null : userProfile.Name;
            String userRoleName = (userRole == null) ? null : userRole.Name;

            if (String.isNotBlank(profileName) && String.isNotBlank(userRoleName)) {
                for (E2EBusiness_Free_Overdraft_Permission__c freeOverdraftPermission : freeOverdraftPermissions) {
                    Boolean profileAndRoleExist = freeOverdraftPermission.Profile_Name__c != null && freeOverdraftPermission.Role_Name__c != null;
                    if (
                        profileAndRoleExist &&
                        freeOverdraftPermission.Profile_Name__c.equalsIgnoreCase(profileName) &&
                        freeOverdraftPermission.Role_Name__c.equalsIgnoreCase(userRoleName)
                    ) {
                        accessibleBySecurity = true;
                    }
                }
            }
        }

        if (e2eBusinessSetting != null) {
            isPPSourceForFreeOverdraft = ppSource == e2eBusinessSetting.PP_Source_for_free_overdraft__c;
        }

        return accessibleBySecurity && companyAgeEnough(formData) && isPPSourceForFreeOverdraft;
    }

    private boolean companyAgeEnough(E2EFormData__c formData) {
        Integer companyAgeInMonths = calculateCompanyAgeInMonths(formData);
        return e2eBusinessSetting != null && e2eBusinessSetting.Company_age__c != null && companyAgeInMonths >= e2eBusinessSetting.Company_age__c;
    }
}